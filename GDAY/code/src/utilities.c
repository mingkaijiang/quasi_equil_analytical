
#include "utilities.h"

void prog_error(const char *reason, const unsigned int line)
{
    fprintf(stderr, "%s, failed at line: %d\n", reason, line);
	exit(EXIT_FAILURE);

    return;
}

bool float_eq(double a, double b) {
    /*
    Are two floats approximately equal...?

    Reference:
    ----------
    D. E. Knuth. The Art of Computer Programming. Sec. 4.2.2 pp. 217-8.
    */
    return fabs(a - b) <= EPSILON * fabs(a);
}



char* rstrip(char* s)
{
    /* Strip whitespace chars off end of given string, in place. Return s. */

    char* p = s + strlen(s);
    while (p > s && isspace(*--p)) *p = '\0';
    return s;
}


char* lskip(char* s)
{
    /* Return pointer to first non-whitespace char in given string. */

    while (*s && isspace(*s)) s++;
    return (char*)s;
}

char* find_char_or_comment(char* s, char c)
{
    /*

    Return pointer to first char c or ';' comment in given string, or
    pointer to null at end of string if neither found. ';' must be
    prefixed by a whitespace character to register as a comment.

    */

    int was_whitespace = 0;
    while (*s && *s != c && !(was_whitespace && *s == ';')) {
        was_whitespace = isspace(*s);
        s++;
    }
    return (char*)s;
}


char *strncpy0(char* dest, char* src, size_t size)
{
    /* Version of strncpy that ensures dest (size bytes) is null-terminated. */

    strncpy(dest, src, size);
    dest[size - 1] = '\0';
    return dest;
}
