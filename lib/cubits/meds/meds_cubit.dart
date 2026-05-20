import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/meds/meds_state.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/models/medication.dart';

export 'meds_state.dart';

class MedicationCubit extends Cubit<MedsState> {
  MedicationCubit(this._repo) : super(const MedsInitial());

  final MedicationRepository _repo;
  String? _email;

  Future<void> load(String email) async {
    _email = email;
    emit(const MedsLoading());
    try {
      final meds = await _repo.getAll(email);
      final day = state is MedsLoaded
          ? (state as MedsLoaded).selectedDay
          : DateTime.now().weekday - 1;
      emit(MedsLoaded(meds: meds, selectedDay: day));
    } catch (e) {
      emit(MedsError(e.toString()));
    }
  }

  void selectDay(int day) {
    final current = state;
    if (current is! MedsLoaded) return;
    emit(current.copyWith(selectedDay: day));
  }

  Future<void> add(Medication med) async {
    if (_email == null) return;
    await _repo.save(med, _email!);
    await _reload();
  }

  Future<void> update(Medication med) async {
    if (_email == null) return;
    await _repo.update(med, _email!);
    await _reload();
  }

  Future<void> delete(String id) async {
    if (_email == null) return;
    await _repo.delete(id, _email!);
    await _reload();
  }

  void clear() {
    _email = null;
    emit(const MedsInitial());
  }

  Future<void> _reload() async {
    if (_email == null) return;
    try {
      final meds = await _repo.getAll(_email!);
      final day = state is MedsLoaded
          ? (state as MedsLoaded).selectedDay
          : DateTime.now().weekday - 1;
      emit(MedsLoaded(meds: meds, selectedDay: day));
    } catch (e) {
      emit(MedsError(e.toString()));
    }
  }
}
