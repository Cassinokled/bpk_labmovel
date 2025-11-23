import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/pics/home-none.svg',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Parece que ainda não tem\nnenhum item aqui...',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryMedium,
              fontFamily: 'Avignon',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
