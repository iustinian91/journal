import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:my_journal/models/journal.dart';
import 'package:my_journal/models/label.dart';
import 'package:my_journal/pages/labels_deligate_page.dart';
import 'package:my_journal/providers/journal_provider.dart';
import 'package:my_journal/utils/date_formatter.dart';
import 'package:my_journal/utils/helpers.dart';
import 'package:my_journal/widgets/quill_editor.dart';
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
    final String todaysDate = DateTime.now().toString();
    return DateFormatter.formatToAppStandard(todaysDate);
  }

  Widget _buildListOfLabels(
    List<Label> labels, {
    required JournalProvider provider,
  }) {
    return Wrap(
      spacing: 4,
      runSpacing: -10,
      children: labels
          .map((e) => ActionChip(
                onPressed: () {
                  _openSearchDelegate(provider);
                },
                label: Text(e.label ?? ''),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ))
          .toList(),
    );
  }

  void _openSearchDelegate(JournalProvider value) async {
    final labels = await showSearch(
      context: context,
      delegate: LabelsDelegatePage(
        journalLabels: value.journalLabels,
      ),
    );

    value.setJournalLabels(labels);
  }

  @override
  void initState() {
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback(((timeStamp) {
        Provider.of<JournalProvider>(context, listen: false)
            .setInitialJournalData(widget.journal);
      }));
    } else {
      WidgetsBinding.instance.addPostFrameCallback(((timeStamp) {
        Provider.of<JournalProvider>(context, listen: false).setJournalTitle();
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
      return WillPopScope(
        onWillPop: () async {
          value.handleSavingJournal(context, isEdit: widget.isEdit);
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => value.handleSavingJournal(
                  context,
                  isEdit: widget.isEdit,
                ),
                icon: const Icon(EvaIcons.chevronLeft),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    _openSearchDelegate(value);
                  },
                  icon: const Icon(Icons.new_label_outlined),
                ),
                widget.isEdit
                    ? IconButton(
                        onPressed: () => _showDeleteDialog(context, value),
                        icon: const Icon(EvaIcons.trashOutline),
                      )
                    : const SizedBox.shrink(),
                IconButton(
                  onPressed: () => value.handleSavingJournal(
                    context,
                    isEdit: widget.isEdit,
                  ),
                  icon: value.state == JournalProviderState.loading
                      ? myCircularProgressIndicator(size: 18)
                      : const Icon(EvaIcons.checkmark),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isEdit)
                          Text(
                            DateFormatter.getJournalCreatedDateWithTime(
                              widget.journal!.createdAt!,
                            ),
                            style: Theme.of(context).textTheme.caption,
                          ),

                        // build labels
                        _buildListOfLabels(value.journalLabels,
                            provider: value),

                        TextFormField(
                          controller: value.titleController,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          decoration: InputDecoration(
                            hintText: _getDefaultJournalTitle(),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 62.0),
                      child: MyQuillEditor.editor(
                        context,
                        controller: value.quillController,
                        autoFocus: !widget.isEdit,
                        placeholder: 'How was your day?',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomSheet: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                spacer(height: 4),
                if (widget.isEdit)
                  if (!DateFormatter.isSameDate(
                    widget.journal!.createdAt!,
                    widget.journal!.updatedAt!,
                  ))
                    Text(
                      'Edited ${DateFormatter.getAppropriateLastEditedTime(
                        widget.journal!.updatedAt!,
                      )}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                MyQuillEditor.toolbar(
                  context,
                  controller: value.quillController,
                ),
                spacer(height: 4),
              ],
            )),
      );
    });
  }

  void _showDeleteDialog(BuildContext context, JournalProvider value) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: getColorScheme(context).surfaceVariant,
            title: const Text('Delete Journal?'),
            content: const Text('This cannot be undone'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  value.deleteJournal();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('DELETE'),
              ),
            ],
            // backgroundColor: lightColorScheme.primaryContainer,
          );
        });
    // value.deleteJournal();
  }
}
