import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String selectedLanguage = 'US';

  final Map<String, String> languages = {
    'US': 'EN',
    'DE': 'DE',
    'FR': 'FR',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('languageCode');
    if (savedLanguage != null) {
      setState(() {
        if (savedLanguage == 'de') {
          selectedLanguage = 'DE';
        } else if (savedLanguage == 'fr') {
          selectedLanguage = 'FR';
        } else {
          selectedLanguage = 'US';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      icon: const Icon(Icons.arrow_drop_down),
      underline: const SizedBox(),
      selectedItemBuilder: (BuildContext context) {
        return languages.keys.map<Widget>((String key) {
          return Row(
            children: [
              SvgPicture.asset(
                'assets/flags/$key.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(languages[key]!),
            ],
          );
        }).toList();
      },
      items: languages.keys.map<DropdownMenuItem<String>>((String key) {
        return DropdownMenuItem<String>(
          value: key,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/flags/$key.svg',
                width: 24,
                height: 24,
                colorFilter: null,
              ),
              const SizedBox(width: 8),
              Text(languages[key]!),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedLanguage = newValue;
            if (newValue == 'US') {
              MyApp.setLocale(context, const Locale('en', ''));
            } else if (newValue == 'DE') {
              MyApp.setLocale(context, const Locale('de', ''));
            } else if (newValue == 'FR') {
              MyApp.setLocale(context, const Locale('fr', ''));
            }
          });
        }
      },
    );
  }
}
