/* parseArgs trait consists of:
 *
 * Usage information printer:
 * void <name>_usage(const char* argv0);
 * 
 * Argument parser:
 * <name> <name>_parseArgs(int argc, char* argv[]);
 * 
 * Available attributes are:
 * - short(Char) – short option name (required)
 * - long(String) – long option name (TODO!)
 * - desc(String) – description of the option
*/

#define impl_parseArgs(name) \
    void name ## _parseArgs(int argc, char* argv[]); \
    void name ## _usage(const char* argv0);
