// Atomic builtins were added in GCC 4.1.
#if  !defined(__GNUC__) \
  || (__GNUC__ < 4) \
  || (__GNUC__ == 4 && __GNUC_MINOR__ < 1)
#error global-lock requires GCC 4.1 or later.
#endif

static void* global = 0;

// Imported 'unsafe' in Haskell code.  Must not block!
void* c_get_global_ptr(void) {
    return global;
}

int c_set_global_ptr(void* new_global) {
    // Set 'global', if it was previously zero.
    void* old = __sync_val_compare_and_swap(&global, 0, new_global);

    // Return true iff we set it successfully.
    return (old == 0);
}
