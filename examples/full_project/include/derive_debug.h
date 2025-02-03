/* Debug trait consists of:
 * 
 * Debug information printer:
 * void <name>_debugPrint(const struct <name>*)
 * 
 * Required Includes:
 * - stdio.h
 */

#define impl_debug(name) \
    void name ## _debugPrint(const struct name *);
