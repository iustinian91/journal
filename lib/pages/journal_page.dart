import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_journal/models/journal.dart';
import 'package:my_journal/providers/journal_provider.dart';
import 'package:my_journal/utils/date_formatter.dart';
import 'package:my_journal/utils/helpers.dart';
import 'package:provider/provider.dart';

class JournalPage extends StatefulWidget {
  final Journal? journal;
  final bool isEdit;
  const JournalPage({
    Key? key,
    this.journal,
    this.isEdit = false,
  }) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String _getDefaultJournalTitle() {
    final String _todaysDate = DateTime.now().toString();
    return DateFormatter.formatToAppStandard(_todaysDate);
  }

  @override
  void initState() {
    if (widget.isEdit) {
      WidgetsBinding.instance!.addPostFrameCallback(((timeStamp) {
        Provider.of<JournalProvider>(context, listen: false)
            .setInitialJournalData(widget.journal);
      }));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(builder: (context, value, child) {
      if (value.state == JournalProviderState.error) {
        showSnackbar(context, value.errorMessage ?? 'Something went wrong');
      }
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => value.handleSavingJournal(
              context,
              isEdit: widget.isEdit,
            ),
            icon: const Icon(EvaIcons.chevronLeft),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          children: [
            TextFormField(
              controller: value.titleController,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: _getDefaultJournalTitle(),
                border: InputBorder.none,
              ),
            ),
            TextFormField(
              controller: value.descriptionController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
              decoration: const InputDecoration(
                hintText: 'How was your day?',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => value.handleSavingJournal(
            context,
            isEdit: widget.isEdit,
          ),
          child: value.state == JournalProviderState.loading
              ? myCircularProgressIndicator(size: 18)
              : const Icon(EvaIcons.checkmark),
        ),
      );
    });
  }
}
