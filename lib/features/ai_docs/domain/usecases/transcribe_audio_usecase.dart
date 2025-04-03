import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template transcribe_audio_usecase}
/// Use case for transcribing audio from a given URL.
/// {@endtemplate}
@lazySingleton
class TranscribeAudioUseCase implements UseCase<String, TranscribeAudioParams> {
  final IAiChatRepository repository;

  /// {@macro transcribe_audio_usecase}
  TranscribeAudioUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(TranscribeAudioParams params) async {
    // Ensure the URL is a valid OSS URL, as required by the API
    // This check might be better placed where the URL is generated (after upload)
    // if (!params.audioOssUrl.startsWith('http')) { // Basic check
    //   return Left(GeneralFailure(message: 'Invalid audio URL for transcription.'));
    // }
    return await repository.transcribeAudio(
      audioOssUrl: params.audioOssUrl,
      userId: params.userId,
    );
  }
}

/// {@template transcribe_audio_params}
/// Parameters required for transcribing audio.
/// {@endtemplate}
class TranscribeAudioParams extends Equatable {
  final String audioOssUrl; // Should be a valid OSS URL
  final int? userId;

  /// {@macro transcribe_audio_params}
  const TranscribeAudioParams({required this.audioOssUrl, this.userId});

  @override
  List<Object?> get props => [audioOssUrl, userId];
} 