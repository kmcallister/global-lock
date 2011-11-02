// Atomic builtins were added in GCC 4.1.
#if  !defined(__GNUC__) \
  || (__GNUC__ < 4) \
  || (__GNUC__ == 4 && __GNUC_MINOR__ < 1)
#error global-lock requires GCC 4.1 or later.
#endif

static void* global = 0;

/*
    If you are copying this file to your own Haskell project, you should
    probably change these function names.  I suggest replacing 'globalzmlock'
    with your package's z-encoded name, following
    <http://hackage.haskell.org/trac/ghc/wiki/Commentary/Compiler/SymbolNames>
*/

// Imported 'unsafe' in Haskell code.  Must not block!
void* hs_globalzmlock_get_global(void) {
    return global;
}

int hs_globalzmlock_set_global(void* new_global) {
    // Set 'global', if it was previously zero.
    void* old = __sync_val_compare_and_swap(&global, 0, new_global);

    // Return true iff we set it successfully.
    return (old == 0);
}
