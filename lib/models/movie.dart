import 'package:flutter/material.dart';

enum DownloadState {
  notDownloaded,
  downloading,
  downloaded,
  expired
}

class CastMember {
  final String name;
  final List<Color> avatarColors;
  final String initials;

  const CastMember({
    required this.name,
    required this.avatarColors,
    required this.initials,
  });
}

class Movie {
  final String id;
  final String title;
  final double rating;
  final String year;
  final String runtime;
  final String ageRating;
  final String qualityBadge;
  final String genres;
  final String synopsis;
  final List<Color> posterColors;
  final bool hasPlayIcon;
  final String? timeRemaining;
  
  // Dynamic state
  bool isInWatchlist;
  DownloadState downloadState;
  double downloadProgress;
  String downloadSize;

  Movie({
    required this.id,
    required this.title,
    required this.rating,
    required this.year,
    required this.runtime,
    this.ageRating = 'PG-13',
    this.qualityBadge = '4K HDR',
    required this.genres,
    required this.synopsis,
    required this.posterColors,
    this.hasPlayIcon = false,
    this.timeRemaining,
    this.isInWatchlist = false,
    this.downloadState = DownloadState.notDownloaded,
    this.downloadProgress = 0.0,
    this.downloadSize = '',
  });

  Movie copyWith({
    bool? isInWatchlist,
    DownloadState? downloadState,
    double? downloadProgress,
    String? downloadSize,
  }) {
    return Movie(
      id: id,
      title: title,
      rating: rating,
      year: year,
      runtime: runtime,
      ageRating: ageRating,
      qualityBadge: qualityBadge,
      genres: genres,
      synopsis: synopsis,
      posterColors: posterColors,
      hasPlayIcon: hasPlayIcon,
      timeRemaining: timeRemaining,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadSize: downloadSize ?? this.downloadSize,
    );
  }
}
