import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import multer from 'multer';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

const app = express();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image uploads are supported.'));
    }
    cb(null, true);
  },
});

const port = process.env.PORT ?? 8080;
const geminiKey = process.env.GEMINI_API_KEY;
const geminiModel = process.env.GEMINI_MODEL ?? 'gemini-1.5-flash';

if (!geminiKey) {
  console.warn(
    '⚠️  GEMINI_API_KEY is not set. The /api/analyze endpoint will fail until you provide a key.',
  );
}

const genAI = geminiKey ? new GoogleGenerativeAI(geminiKey) : null;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'catra-backend', model: geminiModel });
});

app.post('/api/analyze', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Missing image in form-data "file".' });
    }
    if (!genAI) {
      return res
        .status(500)
        .json({ error: 'Server misconfiguration: missing Gemini API key.' });
    }

    const model = genAI.getGenerativeModel({ model: geminiModel });
    const prompt = buildPrompt();
    const response = await model.generateContent([
      {
        inlineData: {
          data: req.file.buffer.toString('base64'),
          mimeType: req.file.mimetype,
        },
      },
      { text: prompt },
    ]);

    const text = response.response?.candidates
      ?.flatMap((candidate) => candidate.content?.parts ?? [])
      .map((part) => part.text ?? '')
      .join('\n')
      .trim();

    if (!text) {
      return res.status(502).json({ error: 'Gemini returned an empty response.' });
    }

    const payload = parseStructuredJson(text);
    if (!payload) {
      return res
        .status(502)
        .json({ error: 'Unable to parse Gemini response into JSON.', raw: text });
    }

    return res.json(payload);
  } catch (error) {
    if (error && error.code === 'NON_FOOD_ITEM' && error.payload?.detail) {
      return res.status(400).json({ detail: error.payload.detail });
    }
    console.error('Analyze failed', error);
    return res.status(500).json({
      error: 'Unexpected server error while analyzing product.',
      details: error.message,
    });
  }
});

app.use((err, _req, res, _next) => {
  if (err instanceof Error && err.message.includes('Only image uploads')) {
    return res.status(400).json({ error: err.message });
  }
  console.error('Unhandled error', err);
  return res.status(500).json({ error: 'Internal server error' });
});

app.listen(port, () => {
  console.log(`CATRA backend running on http://localhost:${port}`);
});

function isNonFoodPrediction(payload) {
  const name = `${payload?.product_name ?? payload?.name ?? ''}`.trim().toLowerCase();
  const nutrition = payload?.nutrition ?? {};

  const macros = ['calories', 'protein', 'fat', 'carbs', 'sugar', 'salt', 'fiber'];
  const hasAnyMacro =
    macros.some((k) => {
      const v = nutrition?.[k];
      if (v === null || v === undefined) return false;
      const num = typeof v === 'number' ? v : Number(String(v).replace(/[^\d.-]/g, ''));
      return !Number.isNaN(num) && num > 0;
    });

  // Heuristics:
  // - Missing/unknown name
  // - No detectable nutrition macros
  const unknownName =
    name.length === 0 ||
    name === 'unknown' ||
    name === 'unknown item' ||
    name === 'non-food' ||
    name.includes('not food');

  return unknownName && !hasAnyMacro;
}

function buildPrompt() {
  return `You are CATRA's nutrition AI. Given a grocery product photo, analyze labels
and respond ONLY in JSON that matches the following schema:
{
  "product_name": "string",
  "expiry": {
    "expiry_date": "YYYY-MM-DD or empty string if unknown",
    "is_expired": boolean,
    "days_left": "integer string or empty"
  },
  "nutrition": {
    "calories": "kcal per 100g/ml",
    "protein": "g per 100g/ml",
    "fat": "g per 100g/ml",
    "carbs": "g per 100g/ml",
    "sugar": "g per 100g/ml",
    "salt": "g per 100g/ml",
    "fiber": "g per 100g/ml"
  },
  "ingredients": {
    "list": ["ordered ingredients"],
    "risky_ingredients": ["potential allergens"],
    "risk_score": 0-100,
    "risk_reason": "short explanation"
  },
  "diet": {
    "is_vegan": boolean or "",
    "is_vegetarian": boolean or "",
    "allergy_alerts": ["strings"],
    "suitable_for": ["diets this fits"]
  },
  "health": {
    "health_score": 0-100,
    "health_explanation": "short sentence"
  },
  "shelf_life": {
    "predicted_shelf_life_days": "integer string or empty",
    "reason": "why"
  }
}
If information is missing, return empty strings instead of hallucinating.`;
}

function parseStructuredJson(text) {
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) return null;
  try {
    const parsed = JSON.parse(jsonMatch[0]);
    // Business rule: if prediction indicates a non-food item, return a 400-friendly payload upstream.
    if (isNonFoodPrediction(parsed)) {
      // Throw a sentinel error object we can recognize in the route handler
      const err = new Error('NON_FOOD_ITEM');
      err.code = 'NON_FOOD_ITEM';
      err.payload = {
        detail:
          'Unknown product - this appears to be a non-food item or not suitable for human consumption',
      };
      throw err;
    }
    return parsed;
  } catch {
    return null;
  }
}

