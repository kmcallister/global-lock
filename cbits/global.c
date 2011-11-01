static void* global = 0;

void* c_get_global_ptr(void) {
    return global;
}

int c_set_global_ptr(void* new_global) {
    // FIXME: this needs to be thread-safe

    if (global)
       return 0;

    global = new_global;
    return 1;
}
