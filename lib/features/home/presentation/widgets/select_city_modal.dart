import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CityItem {
  final String nameEn;
  final String nameAr;
  final String governorateEn;
  final String governorateAr;

  const CityItem({
    required this.nameEn,
    required this.nameAr,
    required this.governorateEn,
    required this.governorateAr,
  });
}

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
  static const List<CityItem> _allKuwaitCities = [
    // 1. Al Asimah (Capital)
    CityItem(nameEn: "Kuwait City", nameAr: "مدينة الكويت", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Sharq", nameAr: "شرق", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Dasman", nameAr: "دسمان", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Mirqab", nameAr: "المرقاب", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Salhiya", nameAr: "الصالحية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Bneid Al-Qar", nameAr: "بنيد القار", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Keifan", nameAr: "كيفان", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Rawda", nameAr: "الروضة", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Adailiya", nameAr: "العديلية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Khaldiya", nameAr: "الخالدية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Qadsiya", nameAr: "القادسية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Yarmouk", nameAr: "اليرموك", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Qurtoba", nameAr: "قرطبة", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Surra", nameAr: "السرة", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Shuwaikh", nameAr: "الشويخ", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Shamiya", nameAr: "الشامية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Dasma", nameAr: "الدسمة", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Mansouriya", nameAr: "المنصورية", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Abdullah Al-Salem", nameAr: "ضاحية عبد الله السالم", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Nuzha", nameAr: "النزهة", governorateEn: "Capital", governorateAr: "العاصمة"),
    CityItem(nameEn: "Faiha", nameAr: "الفيحاء", governorateEn: "Capital", governorateAr: "العاصمة"),

    // 2. Hawalli
    CityItem(nameEn: "Salmiya", nameAr: "السالمية", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Hawalli", nameAr: "حولي", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Rumaithiya", nameAr: "الرميثية", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Jabriya", nameAr: "الجابرية", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Bayan", nameAr: "بيان", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Mishref", nameAr: "مشرف", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Shaab", nameAr: "الشعب", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Salwa", nameAr: "سلوى", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Hittin", nameAr: "حطين", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Al-Siddiq", nameAr: "الصديق", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Al-Shuhada", nameAr: "الشهداء", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Al-Zahra", nameAr: "الزهراء", governorateEn: "Hawalli", governorateAr: "حولي"),
    CityItem(nameEn: "Mubarak Al-Abdullah", nameAr: "غرب مشرف", governorateEn: "Hawalli", governorateAr: "حولي"),

    // 3. Al Farwaniya
    CityItem(nameEn: "Farwaniya", nameAr: "الفروانية", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Khaitan", nameAr: "خيطان", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Omariya", nameAr: "العمرية", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Jleeb Al-Shuyoukh", nameAr: "جليب الشيوخ", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Andalus", nameAr: "الأندلس", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Ishbiliya", nameAr: "إشبيلية", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Ardiya", nameAr: "العارضية", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Reggai", nameAr: "الرقعي", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Sabah Al-Nasser", nameAr: "صباح الناصر", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Firdous", nameAr: "الفردوس", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Rabia", nameAr: "الرابية", governorateEn: "Farwaniya", governorateAr: "الفروانية"),
    CityItem(nameEn: "Rehab", nameAr: "الرحاب", governorateEn: "Farwaniya", governorateAr: "الفروانية"),

    // 4. Al Ahmadi
    CityItem(nameEn: "Ahmadi", nameAr: "الأحمدي", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Fahaheel", nameAr: "الفحيحيل", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Mangaf", nameAr: "المنقف", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Mahboula", nameAr: "المهبولة", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Abu Halifa", nameAr: "أبو حليفة", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Fintas", nameAr: "الفنطاس", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Egaila", nameAr: "العقيلة", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Sabah Al Ahmad", nameAr: "مدينة صباح الأحمد", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Wafra", nameAr: "الوفرة", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Khiran", nameAr: "الخيران", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Bnaider", nameAr: "بنيدر", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Julaia", nameAr: "الجليعة", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),
    CityItem(nameEn: "Mina Abdullah", nameAr: "ميناء عبد الله", governorateEn: "Ahmadi", governorateAr: "الأحمدي"),

    // 5. Mubarak Al-Kabeer
    CityItem(nameEn: "Mubarak Al-Kabeer", nameAr: "مبارك الكبير", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Qurain", nameAr: "القرين", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Qusoor", nameAr: "القصور", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Adan", nameAr: "العدان", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Sabah Al-Salem", nameAr: "صباح السالم", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Funaitees", nameAr: "الفنيطيس", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Abu Ftaira", nameAr: "أبو فطيرة", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Messila", nameAr: "المسيلة", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),
    CityItem(nameEn: "Subhan", nameAr: "صبحان", governorateEn: "Mubarak Al-Kabeer", governorateAr: "مبارك الكبير"),

    // 6. Al Jahra
    CityItem(nameEn: "Jahra", nameAr: "الجهراء", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Saad Al Abdullah", nameAr: "مدينة سعد العبد الله", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Sulaibiya", nameAr: "الصليبية", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Oyoun", nameAr: "العيون", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Qasr", nameAr: "القصر", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Nasseem", nameAr: "النسيم", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Taima", nameAr: "تيماء", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Waha", nameAr: "الواحة", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Kabad", nameAr: "كبد", governorateEn: "Jahra", governorateAr: "الجهراء"),
    CityItem(nameEn: "Abdali", nameAr: "العبدلي", governorateEn: "Jahra", governorateAr: "الجهراء"),
  ];

  String _searchQuery = "";
  String? _selectedGovernorate;

  @override
  Widget build(BuildContext context) {
    final governorates = [
      "All Governorates / كل المحافظات",
      "Capital / العاصمة",
      "Hawalli / حولي",
      "Farwaniya / الفروانية",
      "Ahmadi / الأحمدي",
      "Mubarak Al-Kabeer / مبارك الكبير",
      "Jahra / الجهراء",
    ];

    final filteredCities = _allKuwaitCities.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.nameAr.contains(_searchQuery) ||
          c.governorateEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.governorateAr.contains(_searchQuery);

      final matchesGov = _selectedGovernorate == null ||
          _selectedGovernorate == "All Governorates / كل المحافظات" ||
          c.governorateEn.toLowerCase().contains(_selectedGovernorate!.split(" / ").first.toLowerCase());

      return matchesSearch && matchesGov;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select City / اختر المنطقة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${filteredCities.length} Areas",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Search City Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: "Search Area or Governorate / ابحث عن منطقة...",
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Governorate Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: governorates.map((gov) {
                final isSelected = (_selectedGovernorate == null && gov.startsWith("All")) ||
                    _selectedGovernorate == gov;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(gov, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue.withOpacity(0.15),
                    onSelected: (selected) {
                      setState(() {
                        _selectedGovernorate = gov;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Cities Checkmark List
          Expanded(
            child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final isSelected = city.nameEn == widget.currentCity ||
                    city.nameAr == widget.currentCity;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  title: Row(
                    children: [
                      Text(
                        city.nameEn,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${city.nameAr})",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "${city.governorateEn} Governorate (${city.governorateAr})",
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20)
                      : null,
                  onTap: () {
                    widget.onCitySelected(city.nameEn);
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
