enum AppRoutes {
  splash('splash', '/'),
  onboarding('onboarding', '/onboarding'),
  shell('shell', '/shell'),
  home('home', '/shell/home'),
  scan('scan', '/shell/scan'),
  fridge('fridge', '/shell/fridge'),
  history('history', '/shell/history'),
  settings('settings', '/shell/settings'),
  productDetail('product-detail', '/product/:id'),
  productForm('product-form', '/product-form');

  const AppRoutes(this.name, this.path);

  final String name;
  final String path;
}
