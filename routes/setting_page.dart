import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/url_launcher_helper.dart';
import 'package:workout_app/widgets/listview_item.dart';
import 'package:workout_app/widgets/page_title.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(text: 'Réglages'),
      ),
      body: SizedBox(
        height: AppStyle.pageHeight(context),
        width: AppStyle.pageWidth(context),
        child: ListView(
          children: [
            ListViewItem(
              text: 'Politique de confidentialité',
              onTap: () =>
                  UrlLauncherHelper.urlLauncher(Keys.confidentialityURL),
            ),
            ListViewItem(
                text: 'Conditions d\'utilisation',
                onTap: () => UrlLauncherHelper.urlLauncher(Keys.termOfUseURL)),
            const SizedBox(
              height: 20,
            ),
            Text(
              textAlign: TextAlign.center,
              '© 2024 NICOLAS Thibault. Tous droits résérvés.',
              style: GoogleFonts.roboto(),
            )
          ],
        ),
      ),
    );
  }
}
