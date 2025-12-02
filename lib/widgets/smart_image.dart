import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Widget inteligente que maneja automáticamente imágenes locales y remotas
/// con caché, placeholders y fallbacks robustos
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String fallbackAsset;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackAsset = 'assets/images/logo.png',
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = _buildImage();

    // Si hay borderRadius, envolvemos en ClipRRect
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImage() {
    // ✅ 1. Detectar si es URL remota
    if (_isNetworkUrl(imageUrl)) {
      // Fix temporal para CORS en Flutter Web
      String finalUrl = imageUrl;
      
      // En web, si es Firebase Storage, usar proxy CORS para desarrollo
      if (kIsWeb && imageUrl.contains('firebasestorage.googleapis.com')) {
        // Proxy CORS público para desarrollo (solo para testing)
        // finalUrl = 'https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}';
        
        // Alternativa: usa la URL directamente ya que Firebase permite lectura pública
        finalUrl = imageUrl;
      }
      
      return CachedNetworkImage(
        imageUrl: finalUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildFallback(),
        // Configuración de caché
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        httpHeaders: const {
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    // ✅ 2. Si no es URL, intentar cargar como asset local
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        // Si el asset no existe, mostrar fallback
        return _buildFallback();
      },
    );
  }

  /// Detecta si la URL es remota (http/https)
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Placeholder mientras carga la imagen remota
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
  }

  /// Fallback cuando falla la carga (remota o local)
  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            fallbackAsset,
            fit: BoxFit.contain,
            width: width != null ? width! * 0.5 : 50,
            height: height != null ? height! * 0.5 : 50,
            errorBuilder: (context, error, stackTrace) {
              // Si incluso el fallback falla, mostrar icono
              return Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[400],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}