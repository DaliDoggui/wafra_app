import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SelectCityModal extends StatefulWidget {
  final String currentCity;
  final ValueChanged<String> onCitySelected;

  const SelectCityModal({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
  });

  @override
  State<SelectCityModal> createState() => _SelectCityModalState();
}

class _SelectCityModalState extends State<SelectCityModal> {
  final List<String> _cities = [
    "Kuwait City",
    "Salmiya",
    "Hawalli",
    "Al Jabreya",
    "Surra",
    "Bayan",
    "Mishref",
    "Rawda",
    "Andalous",
    "Fahaheel",
    "Mangaf",
    "Abu Halifa",
    "Mahboula",
    "Sabah Al Ahmad",
    "Al Ahmadi",
    "Al Khiran",
    "Al Wafra",
    "Al Ardhiya",
    "Al Jahra",
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCities = _cities
        .where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
            "Select city",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          // Search City Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: "Search City",
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                suffixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Cities Checkmark List
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isSelected = city == widget.currentCity;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  title: Text(
                    city,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.textPrimary, size: 20)
                      : null,
                  onTap: () {
                    widget.onCitySelected(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
