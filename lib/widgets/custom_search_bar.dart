//dotstudios

import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/widgets/spinner.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    required this.onSubmitted,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.onChanged,
    this.loadingProgressNotifier,
  });
  final Function(String) onSubmitted;
  final ValueNotifier<bool>? loadingProgressNotifier;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final Function(String)? onChanged;

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: SearchBar(
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        hintText: widget.labelText,
        onSubmitted: (String value) {
          widget.onSubmitted(value);
          widget.focusNode.unfocus();
        },
        onChanged: widget.onChanged != null
            ? (value) async {
                widget.onChanged!(value);

                setState(() {});
              }
            : null,
        textInputAction: TextInputAction.search,
        controller: widget.controller,
        focusNode: widget.focusNode,
        trailing: [
          if (widget.loadingProgressNotifier != null)
            ValueListenableBuilder<bool>(
              valueListenable: widget.loadingProgressNotifier!,
              builder: (_, value, __) {
                if (value) {
                  return IconButton(
                    icon: const SizedBox(
                      height: 18,
                      width: 18,
                      child: Spinner(),
                    ),
                    onPressed: () {
                      widget.onSubmitted(widget.controller.text);
                      widget.focusNode.unfocus();
                    },
                  );
                } else {
                  return IconButton(
                    icon: const Icon(
                      HugeIcons.strokeRoundedAiSearch,
                    ),
                    onPressed: () {
                      widget.onSubmitted(widget.controller.text);
                      widget.focusNode.unfocus();
                    },
                  );
                }
              },
            )
          else
            IconButton(
              icon: const Icon(
                HugeIcons.strokeRoundedAiSearch,
              ),
              onPressed: () {
                widget.onSubmitted(widget.controller.text);
                widget.focusNode.unfocus();
              },
            ),
        ],
      ),
    );
  }
}
