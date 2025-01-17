import 'dart:ui';

import 'package:englister/components/study/main/PickModeInput.dart';
import 'package:englister/models/riverpod/StudyModeRiverpod.dart';
import 'package:englister/models/riverpod/StudyRiverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'SpeachEnglish.dart';

class WriteEnglish extends HookConsumerWidget {
  WriteEnglish(
      {Key? key, this.errorMessage, required this.textEditingController})
      : super(key: key);
  String? errorMessage;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isSttMode = ref.watch(sttModeProvider);
    var sttModeNotifier = ref.watch(sttModeProvider.notifier);
    var studyState = ref.watch(studyProvider);
    var studyNotifier = ref.watch(studyProvider.notifier);
    var isPickMode = ref.watch(pickModeProvider);
    var pickModeNotifier = ref.watch(pickModeProvider.notifier);

    Widget renderInputIcons() {
      return Positioned(
          bottom: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  iconSize: 45,
                  color: Colors.blue,
                  icon: const Icon(Icons.keyboard),
                  onPressed: () {
                    pickModeNotifier.set(true);
                  }),
              IconButton(
                  iconSize: 45,
                  color: Colors.blue,
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    sttModeNotifier.set(true);
                  })
            ],
          ));
    }

    Widget renderEnglishTextField() {
      return Stack(
        children: [
          TextField(
            maxLines: 5,
            controller: textEditingController,
            onChanged: (value) {
              studyNotifier.set(studyState.copyWith(english: value));
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: '上の文章を英語にしてください',
              alignLabelWithHint: true,
              errorText: errorMessage,
            ),
          ),
          studyState.english.isEmpty ? renderInputIcons() : Container()
        ],
      );
    }

    Widget renderInputView() {
      if (isSttMode) {
        return SpeachEnglish(textEditingController);
      } else if (isPickMode) {
        return Column(
          children: [
            renderEnglishTextField(),
            PickModeInput(
              textEditingController: textEditingController,
            ),
          ],
        );
      } else {
        return renderEnglishTextField();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black),
            shape: BoxShape.circle,
          ),
          child: const Text("Q",
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
        Text(studyState.activeQuestion.title,
            style: Typography.dense2018.headline5?.apply(fontWeightDelta: 10)),
        Text(studyState.activeQuestion.description,
            style: Typography.dense2018.bodyText2),
        const SizedBox(
          height: 5,
        ),
        Container(
            margin: const EdgeInsets.only(top: 15, bottom: 15),
            color: Colors.grey[300],
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(studyState.japanese,
                  style: Typography.englishLike2018.bodyText1!
                      .apply(color: Colors.black)),
            )),
        const SizedBox(
          height: 5,
        ),
        renderInputView(),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
