import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/data_sharing/infrastructure/repositories/isar_shared_data_repository.dart';
import 'package:n06/features/data_sharing/application/notifiers/data_sharing_notifier.dart';
import 'package:n06/features/onboarding/application/providers.dart';

part 'providers.g.dart';

@riverpod
sharedDataRepository(SharedDataRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarSharedDataRepository(isar);
}

@riverpod
dataSharingNotifier(DataSharingNotifierRef ref) {
  return DataSharingNotifier();
}
