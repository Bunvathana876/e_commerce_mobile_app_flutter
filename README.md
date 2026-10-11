# 🛍️ Modern E-Commerce Mobile App

A clean, responsive, and modern E-Commerce mobile application built with **Flutter** and **Dart**, powered by the **Provider** state management pattern. Designed with a feature-first architecture, smooth page transitions, and a polished user experience.

---

## ✨ Features

### 🔐 Authentication & Onboarding
- **Clean Auth Flow**: Dedicated, separated screens for Welcome, Login, and Sign Up.
- **Form Validation**: Real-time validation for email, password, and user details.
- **Session Management**: Mock/Persistent authentication state via `AuthProvider`.

### 🏠 Home & Discovery
- **Hero & Promotional Banners**: Engaging discount promotions and special offers.
- **Horizontal Category Carousel**: Quick filtering directly on the home screen.
- **Product Grid**: Responsive 2-column layout with discounts, ratings, reviews, and quick "Add to Cart" / Wishlist actions.
- **Search**: Fast, real-time keyword search across all products.

### 🗂️ Categories & Departments
- **Department Cards**: Visual category cards with product counts and high-resolution thumbnails.
- **Browse All Collections**: Quick access to the complete catalog.
- **Dedicated Category Screens**: Tap any department (Electronics, Fashion, Shoes, Gaming, etc.) to view and search items filtered specifically for that department.
- **Zero-Flicker Transitions**: Instant navigation without layout shift or unnecessary animations.

### 📦 Product Details
- **Hero Image Transitions**: Seamless visual continuity when opening products.
- **Variant Selection**: Choose product editions and configurations (Standard, Silver, Pro).
- **Quantity Selector**: Increment/decrement with real-time price calculation.
- **Reviews & Ratings**: Product ratings, review counts, and detailed product descriptions.

### 🛒 Cart & Checkout
- **Interactive Cart**: Increment, decrement, or remove items with instant total calculations.
- **Empty State**: Friendly illustration and call-to-action to explore products.
- **Order Summary**: Breakdown of subtotal, shipping fee, tax, and total.
- **Checkout Process**: Address selection, payment method choices (Credit Card, Apple Pay, Cash on Delivery).
- **Order Success Screen**: Confirmation with order ID, summary, and receipt details.

### ❤️ Wishlist & Favorites
- **Favorites Screen**: Dedicated list of all saved items.
- **One-Tap Actions**: Move favorited items straight to the shopping cart or remove them.

### 👤 Profile & Settings
- **User Profile**: User details, avatar, and quick links to order history, shipping addresses, payment methods, and notification settings.

---

## 🏗️ Project Architecture

The project follows a **Feature-First Architecture** for maintainability and scalability:

```text
lib/
├── app/                  # Top-level app configuration & themes
├── core/
│   ├── theme/            # App color schemes and typography
│   └── utils/            # Page transitions (SmoothPageRoute, NoAnimationPageRoute)
├── features/
│   ├── auth/             # Login, Sign Up, Welcome, AuthProvider
│   ├── cart/             # Cart screen, CartProvider, CartItemModel
│   ├── categories/       # Categories screen, CategoryProductsScreen, CategoryProvider
│   ├── checkout/         # Checkout flow, order success screen, models
│   ├── favorites/        # Wishlist screen and state
│   ├── home/             # Home dashboard screen
│   ├── navigation/       # Main bottom navigation bar (IndexedStack)
│   ├── products/         # Product detail screen, ProductCard, ProductProvider
│   └── profile/          # Profile screen and settings
└── shared/
    └── widgets/          # Reusable UI components (BouncingButton, custom buttons)
```

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.11.1)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [`provider`](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `context.watch`, `context.read`)
- **Icons**: Material Icons & Cupertino Icons
- **Design System**: Material 3 with customized themes and responsive geometry

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (v3.11.0 or higher recommended).
- Android Studio / Xcode / VS Code configured with Flutter plugins.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/e_commerc_mobile_app.git
   cd e_commerc_mobile_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis:**
   ```bash
   flutter analyze
   ```

4. **Run the test suite:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Comprehensive widget and unit tests are included under the `test/` directory:
- `test/widget_test.dart`: App boot and initial screen tests.
- `test/core/utils/page_transitions_test.dart`: Route transition behavior and instant navigation tests.
- `test/features/categories/category_navigation_test.dart`: Department navigation and All Items tests.

Run tests using:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - feel free to use it for personal or commercial projects.
