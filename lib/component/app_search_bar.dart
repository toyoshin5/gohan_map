import 'package:flutter/material.dart';
import 'package:gohan_map/colors/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final Function(String) onSubmitted;
  final bool autofocus;
  const AppSearchBar({
    Key? key,
    required this.onSubmitted,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        //角丸
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.searchBarColorColor,
          borderRadius: BorderRadius.circular(23),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.blackTextColor,
            ),
            Expanded(
              child: TextField(
                autofocus: autofocus,
                cursorColor: AppColors.blackTextColor,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
