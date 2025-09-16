import 'package:flutter/material.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({Key? key}) : super(key: key);

  @override
  State<PlansPage> createState() => _TariffPageState();
}

class _TariffPageState extends State<PlansPage> {
  final List<PackageModel> packages = [
    PackageModel(
      id: 'free',
      title: 'Free',
      priceText: '\$0',
      usersText: '2 users',
    ),
    PackageModel(
      id: 'basic',
      title: 'Basic',
      priceText: '\$69',
      usersText: '5 users',
    ),
    PackageModel(
      id: 'standard',
      title: 'Standard',
      priceText: '\$119',
      usersText: '10 users',
    ),
    PackageModel(
      id: 'business',
      title: 'Business',
      priceText: '\$159',
      usersText: '15 users',
    ),
    PackageModel(
      id: 'ultimate',
      title: 'Ultimate',
      priceText: '>15 users',
      usersText: 'Custom',
      isUltimate: true,
    ),
  ];

  String? selectedPackageId;
  int ultimateEmployees = 16;
  double perEmployeePrice = 9.0;

  @override
  void initState() {
    super.initState();
    selectedPackageId = packages.first.id; // Устанавливаем "Free" как выбранный по умолчанию
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Select the package that fits your team. Tap a card to select it. For Ultimate, enter number of employees to calculate price.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pkg = packages[index];
                final isSelected = selectedPackageId == pkg.id;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2575FC)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    onTap: () {
                      setState(() {
                        selectedPackageId = pkg.id;
                        if (!pkg.isUltimate) {
                          ultimateEmployees = 16;
                        }
                      });
                    },
                    leading: _buildLeading(pkg, isSelected),
                    title: Text(
                      pkg.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF2575FC)
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(pkg.usersText),
                        const SizedBox(height: 6),
                        Text(
                          pkg.isUltimate
                              ? (isSelected
                              ? 'Custom pricing'
                              : '>15 users - choose to calculate')
                              : '${pkg.priceText} • ${pkg.usersText}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        if (pkg.isUltimate && isSelected) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const Text('How many employees?'),
                              _buildEmployeesInput(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Calculated price: ${_formatPrice(_calculateUltimatePrice())}',
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        setState(() {
                          selectedPackageId = pkg.id;
                          if (!pkg.isUltimate) ultimateEmployees = 16;
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildBottomSummary(context),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildLeading(PackageModel pkg, bool isSelected) {
    IconData icon;
    switch (pkg.id) {
      case 'free':
        icon = Icons.volunteer_activism_outlined;
        break;
      case 'basic':
        icon = Icons.star_border;
        break;
      case 'standard':
        icon = Icons.workspace_premium_outlined;
        break;
      case 'business':
        icon = Icons.business_center_outlined;
        break;
      case 'ultimate':
        icon = Icons.shield_outlined;
        break;
      default:
        icon = Icons.circle_outlined;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
            : const LinearGradient(colors: [Colors.grey, Colors.grey]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
    );
  }

  Widget _buildEmployeesInput() {
    return SizedBox(
      width: 120,
      child: TextFormField(
        initialValue: '$ultimateEmployees',
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          final parsed = int.tryParse(val);
          if (parsed != null && parsed >= 16) {
            setState(() {
              ultimateEmployees = parsed;
            });
          }
        },
      ),
    );
  }

  double _calculateUltimatePrice() {
    final count = ultimateEmployees < 16 ? 16 : ultimateEmployees;
    return count * perEmployeePrice;
  }

  String _formatPrice(double value) {
    final rounded = value.toStringAsFixed(0);
    return '\$$rounded';
  }

  Widget _buildBottomSummary(BuildContext context) {
    String summary;
    if (selectedPackageId == null) {
      summary = 'No package selected';
    } else if (selectedPackageId == 'ultimate') {
      summary =
      'Ultimate • $ultimateEmployees users • ${_formatPrice(_calculateUltimatePrice())}';
    } else {
      final pkg = packages.firstWhere((p) => p.id == selectedPackageId);
      summary = '${pkg.title} • ${pkg.priceText} • ${pkg.usersText}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(summary,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: selectedPackageId == null
                ? null
                : () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class PackageModel {
  final String id;
  final String title;
  final String priceText;
  final String usersText;
  final bool isUltimate;

  PackageModel({
    required this.id,
    required this.title,
    required this.priceText,
    required this.usersText,
    this.isUltimate = false,
  });
}