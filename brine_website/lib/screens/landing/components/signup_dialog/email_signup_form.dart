import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../values/insets.dart';

/// A [Form] used to collect a name and email from the visitor so they can be notified about updates for Brine.
class EmailSignupForm extends StatelessWidget {
  const EmailSignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).primaryColorDark,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    OutlineInputBorder errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red[900]!,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    return Form(
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).landingPageEmailInvite,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).nameFieldHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: insetsSmall),
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                errorBorder: errorBorder,
                filled: true,
                fillColor: Theme.of(context).primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
