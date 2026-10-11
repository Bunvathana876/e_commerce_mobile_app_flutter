import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../shared/widgets/bouncing_button.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/address_model.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Available Addresses
  final List<AddressModel> _addresses = [
    const AddressModel(
      id: 1,
      label: 'Home',
      recipientName: 'Bun Vathana',
      phoneNumber: '+855 12 345 678',
      streetAddress: 'Building #45, St. 2004, Sen Sok',
      city: 'Phnom Penh, Cambodia',
      isDefault: true,
    ),
    const AddressModel(
      id: 2,
      label: 'Office / University',
      recipientName: 'Bun Vathana (Year 3)',
      phoneNumber: '+855 98 765 432',
      streetAddress: 'Norton University Campus, Chroy Changvar',
      city: 'Phnom Penh, Cambodia',
      isDefault: false,
    ),
  ];

  late AddressModel _selectedAddress;

  // Shipping Method: 0 = Standard ($0), 1 = Express ($5.00)
  int _selectedShippingIndex = 0;
  final List<Map<String, dynamic>> _shippingMethods = const [
    {
      'title': 'Standard Delivery',
      'subtitle': 'Estimated 3 - 5 business days',
      'price': 0.0,
    },
    {
      'title': 'Express Fast Delivery',
      'subtitle': 'Same day or next business day',
      'price': 5.0,
    },
  ];

  // Payment Method: 0 = ABA KHQR, 1 = Card, 2 = COD
  int _selectedPaymentIndex = 0;
  final List<Map<String, dynamic>> _paymentMethods = const [
    {
      'name': 'ABA / KHQR Pay',
      'subtitle': 'Scan with any mobile banking app',
      'icon': Icons.qr_code_scanner_rounded,
      'color': Color(0xFF005A9C),
    },
    {
      'name': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, UnionPay',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF1E88E5),
    },
    {
      'name': 'Cash on Delivery (COD)',
      'subtitle': 'Pay cash when package arrives',
      'icon': Icons.payments_outlined,
      'color': Color(0xFF10B981),
    },
  ];

  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void _showAddressModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                ...List.generate(_addresses.length, (index) {
                  final addr = _addresses[index];
                  final isSelected = addr.id == _selectedAddress.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAddress = addr);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E88E5).withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E88E5)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? const Color(0xFF1E88E5)
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.label,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${addr.recipientName} (${addr.phoneNumber})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${addr.streetAddress}, ${addr.city}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePlaceOrder(CartProvider cartProvider) async {
    setState(() => _isPlacingOrder = true);

    // Simulate backend payment / order processing network delay
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    final shippingCost =
        _shippingMethods[_selectedShippingIndex]['price'] as double;
    final finalAmount = cartProvider.subtotal + shippingCost;
    final paymentName =
        _paymentMethods[_selectedPaymentIndex]['name'] as String;

    // Clear the cart state
    cartProvider.clearCart();

    setState(() => _isPlacingOrder = false);

    // Navigate to animated order confirmation screen
    Navigator.of(context).pushReplacement(
      SmoothPageRoute(
        page: OrderSuccessScreen(
          grandTotal: finalAmount,
          paymentMethod: paymentName,
          addressCity: _selectedAddress.city,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final shippingCost =
        _shippingMethods[_selectedShippingIndex]['price'] as double;
    final finalGrandTotal = cartProvider.subtotal + shippingCost;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Scrollable Checkout Details
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
            children: [
              // --- Section 1: Delivery Address ---
              _buildSectionHeader('Delivery Address'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF1E88E5),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedAddress.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${_selectedAddress.recipientName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress.phoneNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_selectedAddress.streetAddress}, ${_selectedAddress.city}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _showAddressModal,
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Section 2: Shipping Method ---
              _buildSectionHeader('Shipping Method'),
              const SizedBox(height: 8),
              ...List.generate(_shippingMethods.length, (index) {
                final method = _shippingMethods[index];
                final isSelected = _selectedShippingIndex == index;
                final price = method['price'] as double;

                return GestureDetector(
                  onTap: () => setState(() => _selectedShippingIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                method['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          price == 0.0
                              ? 'FREE'
                              : '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: price == 0.0
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              // --- Section 3: Payment Method ---
              _buildSectionHeader('Payment Method'),
              const SizedBox(height: 8),
              ...List.generate(_paymentMethods.length, (index) {
                final pay = _paymentMethods[index];
                final isSelected = _selectedPaymentIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPaymentIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (pay['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            pay['icon'] as IconData,
                            size: 20,
                            color: pay['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pay['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                pay['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              // --- Section 4: Cost Breakdown ---
              _buildSectionHeader('Order Summary'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    _priceRow(
                      'Cart Subtotal',
                      '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _priceRow(
                      'Shipping Fee',
                      shippingCost == 0.0
                          ? 'FREE'
                          : '\$${shippingCost.toStringAsFixed(2)}',
                      valueColor: shippingCost == 0.0
                          ? const Color(0xFF10B981)
                          : null,
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _priceRow(
                      'Total Amount',
                      '\$${finalGrandTotal.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Sticky Bottom Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: BouncingButton(
                  onTap: _isPlacingOrder
                      ? null
                      : () => _handlePlaceOrder(cartProvider),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pay • \$${finalGrandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color:
                valueColor ??
                (isBold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}
