/*
 * WCMD - Wine-compatible command line interface - built-in functions.
 *
 * (C) 1999 D A Pickles
 *
 * On entry to each function, global variables quals, param1, param2 contain
 * the qualifiers (uppercased and concatenated) and parameters entered, with
 * environment-variable and batch parameter substitution already done.
 */

/*
 * FIXME:
 * - No support for redirection, pipes, batch files, shell parameters
 * - 32-bit limit on file sizes in DIR command
 * - Lots of functionality missing from builtins
 * - Messages etc need international support
 */

#include "wcmd.h"

extern HANDLE STDin, STDout;
extern HINSTANCE hinst;
extern char *inbuilt[];
extern char nyi[];
extern char newline[];
extern char version_string[];
extern char anykey[];
extern int echo_mode;
extern char quals[MAX_PATH], param1[MAX_PATH], param2[MAX_PATH];


/****************************************************************************
 * WCMD_call
 *
 * Call another batch file.
 */

void WCMD_call () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_clear_screen
 *
 * Clear the terminal screen.
 */

void WCMD_clear_screen () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_change_tty
 *
 * Change the default i/o device (ie redirect STDin/STDout).
 */

void WCMD_change_tty () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_copy
 *
 * Copy a file or wildcarded set.
 * FIXME: No wildcard support
 * FIXME: Needs output file to be fully specified (can't just enter directory)
 */

void WCMD_copy () {

DWORD count;
WIN32_FIND_DATA fd;
HANDLE hff;
BOOL force, status;
static char *overwrite = "Overwrite file (Y/N)?";
char string[8], outpath[MAX_PATH];

  if ((strchr(param1,'*') != NULL) && (strchr(param1,'%') != NULL)) {
    WCMD_output ("Wildcards not yet supported\n");
    return;
  }
  GetFullPathName (param2, sizeof(outpath), outpath, NULL);
  force = (strstr (quals, "/Y") != NULL);
  if (!force) {
    hff = FindFirstFile (outpath, &fd);
    if (hff != INVALID_HANDLE_VALUE) {
      FindClose (hff);
      WCMD_output (overwrite);
      ReadFile (STDin, string, sizeof(string), &count, NULL);
      if (toupper(string[0]) == 'Y') force = TRUE;
    }
    else force = TRUE;
  }
  if (force) {
    status = CopyFile (param1, outpath, FALSE);
    if (!status) WCMD_print_error ();
  }
}

/****************************************************************************
 * WCMD_create_dir
 *
 * Create a directory.
 */

void WCMD_create_dir () {

  if (!CreateDirectory (param1, NULL)) WCMD_print_error ();
}

/****************************************************************************
 * WCMD_delete
 *
 * Delete a file or wildcarded set.
 *
 */

void WCMD_delete (int recurse) {

WIN32_FIND_DATA fd;
HANDLE hff;
char fpath[MAX_PATH];
char *p;

  hff = FindFirstFile (param1, &fd);
  if (hff == INVALID_HANDLE_VALUE) {
    WCMD_output ("File Not Found\n");
    return;
  }
  if ((strchr(param1,'*') == NULL) && (strchr(param1,'?') == NULL)
  	&& (!recurse) && (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
    strcat (param1, "\\*");
    WCMD_delete (1);
    return;
  }
  if ((strchr(param1,'*') != NULL) || (strchr(param1,'?') != NULL)) {
    strcpy (fpath, param1);
    do {
      p = strrchr (fpath, '\\');
      if (p != NULL) {
        *++p = '\0';
        strcat (fpath, fd.cFileName);
      }
      else strcpy (fpath, fd.cFileName);
      if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
        if (!DeleteFile (fpath)) WCMD_print_error ();
      }
    } while (FindNextFile(hff, &fd) != 0);
    FindClose (hff);
  }
  else {
    if (!DeleteFile (param1)) WCMD_print_error ();
  }
}

/****************************************************************************
 * WCMD_echo
 *
 * Echo input to the screen (or not). We don't try to emulate the bugs
 * in DOS (try typing "ECHO ON AGAIN" for an example).
 */

void WCMD_echo (char *command) {

static char *eon = "Echo is ON\n", *eoff = "Echo is OFF\n";
int count;

  count = strlen(command);
  if (count == 0) {
    if (echo_mode) WCMD_output (eon);
    else WCMD_output (eoff);
    return;
  }
  if ((count == 1) && (command[0] == '.')) {
    WCMD_output (newline);
    return;
  }
  if (lstrcmpi(command, "ON") == 0) {
    echo_mode = 1;
    return;
  }
  if (lstrcmpi(command, "OFF") == 0) {
    echo_mode = 0;
    return;
  }
  WCMD_output (command);
  WCMD_output (newline);

}

/****************************************************************************
 * WCMD_for
 *
 * Batch file loop processing.
 */

void WCMD_for () {

  WCMD_output (nyi);

}

/**************************************************************************
 * WCMD_give_help
 *
 *	Simple on-line help. Help text is stored in the resource file.
 */

void WCMD_give_help (char *command) {

int i;
char buffer[2048];

  command = WCMD_strtrim_leading_spaces(command);
  if (lstrlen(command) == 0) {
    LoadString (hinst, 1000, buffer, sizeof(buffer));
    WCMD_output (buffer);
  }
  else {
    for (i=0; i<=WCMD_EXIT; i++) {
      if (CompareString (LOCALE_USER_DEFAULT, NORM_IGNORECASE | SORT_STRINGSORT,
      	  param1, -1, inbuilt[i], -1) == 2) {
        LoadString (hinst, i, buffer, sizeof(buffer));
        WCMD_output (buffer);
        return;
      }
    }
    WCMD_output ("No help available for %s\n", param1);
  }
  return;
}

/****************************************************************************
 * WCMD_if
 *
 * Batch file conditional.
 */

void WCMD_if () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_move
 *
 * Move a file, directory tree or wildcarded set of files.
 */

void WCMD_move () {

  WCMD_output (nyi);
}

/****************************************************************************
 * WCMD_pause
 *
 * Wait for keyboard input.
 */

void WCMD_pause () {

DWORD count;
char string[32];

  WCMD_output (anykey);
  ReadFile (STDin, string, sizeof(string), &count, NULL);
}

/****************************************************************************
 * WCMD_remove_dir
 *
 * Delete a directory.
 */

void WCMD_remove_dir () {

  if (!RemoveDirectory (param1)) WCMD_print_error ();
}

/****************************************************************************
 * WCMD_rename
 *
 * Rename a file.
 * FIXME: Needs input and output files to be fully specified.
 */

void WCMD_rename () {

int status;
static char *dirmsg = "Input file is a directory. Use the MOVE command\n\n";

  if ((strchr(param1,'*') != NULL) || (strchr(param1,'%') != NULL)) {
    WCMD_output ("Wildcards not yet supported\n");
    return;
  }
  status = GetFileAttributes (param1);
  if ((status != -1) && (status & FILE_ATTRIBUTE_DIRECTORY)) {
    WCMD_output (dirmsg);
    return;
  }
  status = MoveFile (param1, param2);
  if (!status) WCMD_print_error ();
}

/*****************************************************************************
 * WCMD_setshow_attrib
 *
 * Display and optionally sets DOS attributes on a file or directory
 *
 * FIXME: Wine currently uses the Unix stat() function to get file attributes.
 * As a result only the Readonly flag is correctly reported, the Archive bit
 * is always set and the rest are not implemented. We do the Right Thing anyway.
 *
 */

void WCMD_setshow_attrib () {

DWORD count;
HANDLE hff;
WIN32_FIND_DATA fd;
char flags[9] = {"        "};

  if (lstrlen(param1) == 0) {
    GetCurrentDirectory (sizeof(param1), param1);
    strcat (param1, "\\*");
  }

  hff = FindFirstFile (param1, &fd);
  if (hff == INVALID_HANDLE_VALUE) {
    WCMD_output ("File Not Found\n");
  }
  else {
    do {
      if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN) {
	  flags[0] = 'H';
	}
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_SYSTEM) {
	  flags[1] = 'S';
	}
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_ARCHIVE) {
	  flags[2] = 'A';
	}
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_READONLY) {
	  flags[3] = 'R';
	}
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_TEMPORARY) {
	  flags[4] = 'T';
	}
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_COMPRESSED) {
	  flags[5] = 'C';
	}
        WCMD_output ("%s   %s\n", flags, fd.cFileName);
	for (count=0; count < 8; count++) flags[count] = ' ';
      }
    } while (FindNextFile(hff, &fd) != 0);
  }
  FindClose (hff);
}

/*****************************************************************************
 * WCMD_setshow_default
 *
 *	Set/Show the current default directory
 */

void WCMD_setshow_default () {

BOOL status;
char string[1024];

  if (strlen(param1) == 0) {
    GetCurrentDirectory (sizeof(string), string);
    strcat (string, "\n");
    WCMD_output (string);
  }
  else {
    status = SetCurrentDirectory (param1);
    if (!status) {
      WCMD_print_error ();
      return;
    }
   }
  return;
}

/****************************************************************************
 * WCMD_setshow_date
 *
 * Set/Show the system date
 * FIXME: Can't change date yet
 */

void WCMD_setshow_date () {

char curdate[64], buffer[64];
DWORD count;

  if (lstrlen(param1) == 0) {
    if (GetDateFormat (LOCALE_USER_DEFAULT, 0, NULL, NULL,
  		curdate, sizeof(curdate))) {
      WCMD_output ("Current Date is %s\nEnter new date: ", curdate);
      ReadFile (STDin, buffer, sizeof(buffer), &count, NULL);
      if (count > 2) {
        WCMD_output (nyi);
      }
    }
    else WCMD_print_error ();
  }
  else {
    WCMD_output (nyi);
  }
}

/****************************************************************************
 * WCMD_setshow_env
 *
 * Set/Show the environment variables
 *
 * FIXME: need to sort variables into order for display?
 */

void WCMD_setshow_env (char *s) {

LPVOID env;
char *p;
int status;

  if (strlen(param1) == 0) {
    env = GetEnvironmentStrings ();
    p = (char *) env;
    while (*p) {
      WCMD_output ("%s\n", p);
      p += lstrlen(p) + 1;
    }
  }
  else {
    p = strchr (s, '=');
    if (p == NULL) {
      WCMD_output ("Command Syntax: SET variable=value\n");
      return;
    }
    *p++ = '\0';
    status = SetEnvironmentVariable (s, p);
    if (!status) WCMD_print_error();
  }
  WCMD_output (newline);
}

/****************************************************************************
 * WCMD_setshow_path
 *
 * Set/Show the path environment variable
 */

void WCMD_setshow_path () {

char string[1024];
DWORD status;

  if (strlen(param1) == 0) {
    status = GetEnvironmentVariable ("PATH", string, sizeof(string));
    if (status != 0) {
      WCMD_output ("PATH=%s\n", string);
    }
    else {
      WCMD_output ("PATH not found\n");
    }
  }
  else {
    status = SetEnvironmentVariable ("PATH", param1);
    if (!status) WCMD_print_error();
  }
}

/****************************************************************************
 * WCMD_setshow_prompt
 *
 * Set or show the command prompt.
 */

void WCMD_setshow_prompt () {

char *s;

  if (strlen(param1) == 0) {
    SetEnvironmentVariable ("PROMPT", NULL);
  }
  else {
    s = param1;
    while ((*s == '=') || (*s == ' ')) s++;
    if (strlen(s) == 0) {
      SetEnvironmentVariable ("PROMPT", NULL);
    }
    else SetEnvironmentVariable ("PROMPT", s);
  }
}

/****************************************************************************
 * WCMD_setshow_time
 *
 * Set/Show the system time
 * FIXME: Can't change time yet
 */

void WCMD_setshow_time () {

char curtime[64], buffer[64];
DWORD count;

  if (strlen(param1) == 0) {
    if (GetTimeFormat (LOCALE_USER_DEFAULT, 0, NULL, NULL,
  		curtime, sizeof(curtime))) {
      WCMD_output ("Current Time is %s\nEnter new time: ", curtime);
      ReadFile (STDin, buffer, sizeof(buffer), &count, NULL);
      if (count > 2) {
        WCMD_output (nyi);
      }
    }
    else WCMD_print_error ();
  }
  else {
    WCMD_output (nyi);
  }
}

/****************************************************************************
 * WCMD_shift
 *
 * Shift batch parameters.
 */

void WCMD_shift () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_type
 *
 * Copy a file to standard output.
 */

void WCMD_type () {

HANDLE h;
char buffer[512];
DWORD count;

  h = CreateFile (param1, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING,
  		FILE_ATTRIBUTE_NORMAL, 0);
  if (h == INVALID_HANDLE_VALUE) {
    WCMD_print_error ();
    return;
  }
  while (ReadFile (h, buffer, sizeof(buffer), &count, NULL)) {
    if (count == 0) break;	/* ReadFile reports success on EOF! */
    WriteFile (STDout, buffer, count, &count, NULL);
  }
  CloseHandle (h);
}

/****************************************************************************
 * WCMD_verify
 *
 * Display verify flag.
 */

void WCMD_verify () {

  WCMD_output (nyi);

}

/****************************************************************************
 * WCMD_version
 *
 * Display version info.
 */

void WCMD_version () {

  WCMD_output (version_string);

}

/****************************************************************************
 * WCMD_volume
 *
 * Display volume info and/or set volume label. Returns 0 if error.
 */

int WCMD_volume (int mode, char *path) {

DWORD count, serial;
char string[MAX_PATH], label[MAX_PATH], curdir[MAX_PATH];
BOOL status;
static char syntax[] = "Syntax Error\n\n";

  if (lstrlen(path) == 0) {
    status = GetCurrentDirectory (sizeof(curdir), curdir);
    if (!status) {
      WCMD_print_error ();
      return 0;
    }
    status = GetVolumeInformation (NULL, label, sizeof(label), &serial, NULL,
    	NULL, NULL, 0);
  }
  else {
    if ((path[1] != ':') || (lstrlen(path) != 2)) {
      WriteFile (STDout, syntax, strlen(syntax), &count, NULL);
      return 0;
    }
    wsprintf (curdir, "%s\\", path);
    status = GetVolumeInformation (curdir, label, sizeof(label), &serial, NULL,
    	NULL, NULL, 0);
  }
  if (!status) {
    WCMD_print_error ();
    return 0;
  }
  WCMD_output ("Volume in drive %c is %s\nVolume Serial Number is %04x-%04x\n\n",
    	curdir[0], label, HIWORD(serial), LOWORD(serial));
  if (mode) {
    WCMD_output ("Volume label (11 characters, ENTER for none)?");
    ReadFile (STDin, string, sizeof(string), &count, NULL);
    if (lstrlen(path) != 0) {
      if (!SetVolumeLabel (curdir, string)) WCMD_print_error ();
    }
    else {
      if (!SetVolumeLabel (NULL, string)) WCMD_print_error ();
    }
  }
  return 1;
}
