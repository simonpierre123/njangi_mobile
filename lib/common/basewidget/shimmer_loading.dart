import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Applique un reflet animé sur tous les [SkeletonBox] de son sous-arbre.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder:
          (context, child) => ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: const [
                    AppColors.neutralGrayLighter,
                    AppColors.white,
                    AppColors.neutralGrayLighter,
                  ],
                  stops: const [0.3, 0.5, 0.7],
                  transform: _SlideGradientTransform(_controller.value),
                ).createShader(bounds),
            child: child,
          ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
}

/// Bloc plein à placer sous un [Shimmer] ; sa couleur est remplacée par le reflet.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.isCircle = false,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutralGrayLighter,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Image réseau qui affiche un shimmer pendant son téléchargement.
class ShimmerNetworkImage extends StatelessWidget {
  const ShimmerNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Shimmer(
          child: SkeletonBox(width: width, height: height, radius: 0),
        );
      },
    );
  }
}
