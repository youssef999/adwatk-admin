import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../models/note_audience.dart';
import '../models/note_banner_model.dart';
import '../models/note_type.dart';
import '../repositories/notes_repository.dart';

class NotesController extends GetxController {
  NotesController({NotesRepository? repository})
      : _repository = repository ?? NotesRepository();

  final NotesRepository _repository;

  static const String listId = 'notes_list';
  static const String formId = 'notes_form';

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final searchController = TextEditingController();

  List<NoteBannerModel> notes = [];
  String searchQuery = '';
  String noteTo = NoteAudience.clients;
  String noteType = NoteType.noti;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<NoteBannerModel> get filteredNotes {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return notes;
    return notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.details.toLowerCase().contains(q) ||
          n.type.toLowerCase().contains(q) ||
          n.typeLabelAr.contains(q) ||
          n.to.toLowerCase().contains(q) ||
          n.toLabelAr.contains(q) ||
          n.customerEmail.toLowerCase().contains(q) ||
          n.customerPhone.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  @override
  void onClose() {
    titleController.dispose();
    detailsController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadNotes() async {
    isLoading = true;
    errorMessage = null;
    update([listId]);
    try {
      notes = await _repository.fetchNotes();
    } catch (_) {
      errorMessage = 'تعذر تحميل الملاحظات.';
    } finally {
      isLoading = false;
      update([listId]);
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    update([listId]);
  }

  void prepareCreate() {
    titleController.clear();
    detailsController.clear();
    noteType = NoteType.noti;
    noteTo = NoteAudience.clients;
    update([formId]);
  }

  void setNoteTo(String value) {
    noteTo = NoteAudience.normalize(value);
    update([formId]);
  }

  void setNoteType(String value) {
    noteType = NoteType.normalize(value);
    update([formId]);
  }

  Future<bool> submitNote() async {
    final title = titleController.text.trim();
    final details = detailsController.text.trim();

    if (title.isEmpty) {
      AppSnackbar.error('عنوان الملاحظة مطلوب.');
      return false;
    }
    if (details.isEmpty) {
      AppSnackbar.error('تفاصيل الملاحظة مطلوبة.');
      return false;
    }

    isSubmitting = true;
    update([formId]);
    try {
      final note = await _repository.createNote(
        title: title,
        details: details,
        type: noteType,
        to: noteTo,
      );
      notes = [note, ...notes];
      update([listId]);
      return true;
    } catch (_) {
      AppSnackbar.error('تعذر إضافة الملاحظة.');
      return false;
    } finally {
      isSubmitting = false;
      update([formId]);
    }
  }

  Future<void> deleteNote(NoteBannerModel note) async {
    try {
      await _repository.deleteNote(note.id);
      notes.removeWhere((n) => n.id == note.id);
      AppSnackbar.success('تم حذف الملاحظة.');
      update([listId]);
    } catch (_) {
      AppSnackbar.error('تعذر حذف الملاحظة.');
    }
  }
}
