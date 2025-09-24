import 'package:flutter/material.dart';

class StateColors {
  static Map<String, dynamic> getStateColors(String stateName) {
    switch (stateName) {
      // AMAZONIA (light green)
      case 'Amazonas':
      case 'Pará':
      case 'Acre':
      case 'Roraima':
      case 'Rondônia':
      case 'Amapá':
        return {
          'normal': {
            'fill': Color(
              0xFF34D399,
            ).withValues(alpha: 0.7).value, // Brighter green
            'outline': Color(0xFF047857).value, //
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };

      // CERRADO (yellow)
      case 'Mato Grosso':
      case 'Mato Grosso do Sul':
      case 'Goiás':
      case 'Tocantins':
      case 'Distrito Federal':
        return {
          'normal': {
            'fill': Color(0xFFFEF08A).withValues(alpha: 0.6).value,
            'outline': Color(0xFFCA8A04).value,
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };

      // MATA ATLANTICA (dark green)
      case 'São Paulo':
      case 'Rio de Janeiro':
      case 'Espírito Santo':
      case 'Minas Gerais':
      case 'Paraná':
      case 'Santa Catarina':
      case 'Rio Grande do Sul':
        return {
          'normal': {
            'fill': Color(0xFF22C55E).withValues(alpha: 0.5).value,
            'outline': Color(0xFF15803D).value,
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };

      // CAATINGA (orange/red)
      case 'Bahia':
      case 'Ceará':
      case 'Pernambuco':
      case 'Paraíba':
      case 'Rio Grande do Norte':
      case 'Alagoas':
      case 'Sergipe':
      case 'Piauí':
      case 'Maranhão':
        return {
          'normal': {
            'fill': Color(0xFFFB7185).withValues(alpha: 0.5).value,
            'outline': Color(0xFFDC2626).value,
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };

      // PANTANAL (light yellow/beige)
      case 'Pantanal': // This might be part of Mato Grosso in your data
        return {
          'normal': {
            'fill': Color(0xFFFEF3C7).withValues(alpha: 0.6).value,
            'outline': Color(0xFFD97706).value,
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };

      default:
        // Default gray for any unmatched states
        return {
          'normal': {
            'fill': Color(0xFF6B7280).withValues(alpha: 0.3).value,
            'outline': Color(0xFF4B5563).value,
          },
          'highlight': {
            'fill': Color(0xFF374151).withValues(alpha: 0.4).value,
            'outline': Color(0xFF1F2937).value,
          },
        };
    }
  }
}
