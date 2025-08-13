# Issue #86 Fix: Cover Image Upload Causing Unexpected Page Exit

## Problem Description
When users upload a cover image in the product edit page after filling in other information, the page unexpectedly exits and shows "saved as draft" message. This happens because of an unintended interaction between the auto-save mechanism and the navigation logic.

## Root Cause Analysis

### The Bug Flow:
1. User uploads a cover image → triggers `SelectProductImages` event
2. Image upload completes → triggers auto-save mechanism after 2 seconds
3. Auto-save completes → sets `isDraftSaveSuccess = true` in state
4. BlocConsumer listener detects `isDraftSaveSuccess` → calls `Navigator.pop()`
5. Page unexpectedly exits

### The Problem:
The page has a BlocConsumer listener (line 1013-1030 in product_edit_page.dart) that automatically navigates back when `isDraftSaveSuccess` is true. This was intended for manual draft saves but was being triggered by auto-saves after image uploads.

## Solution Implemented

### 1. Modified SaveProductDraft Event
Added an `isAutoSave` flag to distinguish between manual and automatic saves:

```dart
// product_edit_event.dart
class SaveProductDraft extends ProductEditEvent {
  final bool isAutoSave;
  
  const SaveProductDraft({
    this.isAutoSave = false,
  });
  
  @override
  List<Object?> get props => [isAutoSave];
}
```

### 2. Updated Auto-save Mechanism
Modified `_scheduleAutoSave` to pass `isAutoSave: true`:

```dart
// product_edit_bloc.dart
void _scheduleAutoSave() {
  _autoSaveTimer?.cancel();
  
  _autoSaveTimer = Timer(const Duration(seconds: 2), () {
    if (state.hasUnsavedChanges && !state.isSavingDraft) {
      add(const SaveProductDraft(isAutoSave: true));  // Pass isAutoSave flag
    }
  });
}
```

### 3. Modified Save Handler
Updated `_onSaveProductDraft` to only set `isDraftSaveSuccess` for manual saves:

```dart
// product_edit_bloc.dart
result.fold(
  (failure) => emit(state.copyWithError(failure.message)),
  (success) {
    if (!event.isAutoSave) {
      // Manual save: Set success flag to trigger navigation
      emit(state.copyWithDraftSaveSuccess().copyWith(
        selectedImagePaths: [],
        selectedDetailImagePaths: [],
      ));
    } else {
      // Auto-save: Update state without success flag
      emit(state.copyWith(
        isSavingDraft: false,
        hasUnsavedChanges: false,
        selectedImagePaths: [],
        selectedDetailImagePaths: [],
      ));
    }
    add(SetInitialFormData(initialData: state.formData));
  },
);
```

## Files Modified
1. `lib/features/seller/presentation/bloc/product_edit/product_edit_event.dart`
2. `lib/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart`

## Testing Recommendations
1. Test uploading cover images - page should NOT exit
2. Test manual "Save Draft" button - page SHOULD exit
3. Test with multiple image uploads in succession
4. Test with success case images (which also trigger auto-save)
5. Test in both create and edit modes

## Impact
- Auto-saves will continue to work silently in the background
- Manual draft saves will still navigate back as expected
- Image uploads will no longer cause unexpected page exits
- User experience is significantly improved

## Future Improvements
Consider adding:
1. Visual indicator when auto-save is in progress
2. Toast notification for successful auto-saves
3. Configurable auto-save delay
4. Option to disable auto-save in settings