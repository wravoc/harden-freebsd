#include <sys/mman.h>
#include <stdio.h>

// Author: u/zabolekar
// URL: https://www.reddit.com/r/BSD/comments/10isrl3/notes_about_mmap_mprotect_and_wx_on_different_bsd/
// Customized by Quadhelion Engineering
// Compile it with cc mmap_mprotect.c, run it with ./a.out

int main()
{
    void* p = mmap(NULL, 1, PROT_WRITE|PROT_EXEC, MAP_ANON|MAP_PRIVATE, -1, 0);

    if (p == MAP_FAILED)
    {
        perror("\n*********************\033[38;5;76m Success \033[0;0m*************************\n Permission denied for shared memory map write and execute\n*******************************************************\n");
    }
    else
    {
        puts("\033[38;5;1mVULNERABLE\033[0;0m: Writable and executable memory mapped successfully");
        munmap(p, 1);
    }

    p = mmap(NULL, 1, PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0);
    if (p == MAP_FAILED)
    {
        perror("Map writable memory");
    }
    else
    {
        puts("\n * Writable memory mapped successfully");

        if (mprotect(p, 1, PROT_EXEC))
            perror("Can't make writable memory executable");
        else
            puts(" * Preparing writable memory for execution");

        if (mprotect(p, 1, PROT_WRITE|PROT_EXEC))
            perror("\n*********************\033[38;5;76m Success \033[0;0m*************************\n Can't make shared memory writable and executable\n*******************************************************\n");
        else
            puts("\033[38;5;1mVULNERABLE\033[0;0m: Shared memory successfully made writable and executable");

        munmap(p, 1);
    }
    puts("\n");
}