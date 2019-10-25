#ifndef MyTools_H
#define MyTools_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include "Python.h"
#include "pythread.h"

using namespace std;

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

//#define WINDOWS
#define LINUX 1

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

#ifdef WINDOWS

#include <process.h>
#include <windows.h>

#define CRITICAL_VAR             CRITICAL_SECTION
#define INIT_CRITICAL_VAR(v)     InitializeCriticalSection(&(v))
#define ENTER_CRITICAL(v)        EnterCriticalSection(&(v))
#define LEAVE_CRITICAL(v)        LeaveCriticalSection(&(v))
#define DELETE_CRITICAL_VAR(v)   DeleteCriticalSection(&(v))

#else

#include <unistd.h>
#include <sys/time.h>
#include <pthread.h>
#define CRITICAL_VAR             pthread_mutex_t
#define INIT_CRITICAL_VAR(v)     pthread_mutex_init(&(v), NULL);
#define ENTER_CRITICAL(v)        pthread_mutex_lock(&(v))
#define LEAVE_CRITICAL(v)        pthread_mutex_unlock(&(v))
#define DELETE_CRITICAL_VAR(v)   pthread_mutex_destroy(&(v))

#endif

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

class CCriticalSection
{
public:
    CCriticalSection()
    {
        INIT_CRITICAL_VAR(cv);
    }

    ~CCriticalSection()
    {
        DELETE_CRITICAL_VAR(cv);
    }

    void Lock()
    {
        ENTER_CRITICAL(cv);
    }

    void UnLock()
    {
        LEAVE_CRITICAL(cv);
    }

private:
    CRITICAL_VAR   cv;
};
CCriticalSection g_cv;

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

class PyGILLock
{
public:
  PyGILLock()
  {
      m_gil_state = PyGILState_Ensure();
  }

  ~PyGILLock()
  {
      PyGILState_Release(m_gil_state);
  }

private:
  PyGILState_STATE m_gil_state;
};

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

/// 单调递增时间
#ifdef WINDOWS
int get_tick_count()
{
    return int(GetTickCount());
}
#else
int get_tick_count()
{
    timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}
#endif

/*
class MyTimer {

private:

#ifdef WINDOWS
LARGE_INTEGER large_integer;
    LARGE_INTEGER large_integer;
    __int64 IntStart;
    __int64 IntEnd;
    double DobDff;
    double DobMillseconds;
#endif

public:
    MyTimer() {};

    void TimerStart() {
        QueryPerformanceFrequency(&large_integer);
        DobDff = large_integer.QuadPart;

        QueryPerformanceCounter(&large_integer);
        IntStart = large_integer.QuadPart;
    }

    double TimerFinish() {
        QueryPerformanceCounter(&large_integer);
        IntEnd = large_integer.QuadPart;
        DobMillseconds = (IntEnd - IntStart) * 1000 / DobDff; //转为ms
        return DobMillseconds;
    }
};
*/

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

bool check_version()
{
#ifdef WIN32
    SYSTEMTIME st;
    GetLocalTime(&st);
    int h = st.wHour;
    int m = st.wMinute;
    int s = st.wSecond;
    int ms = st.wMilliseconds;

    int y = st.wYear;
    int mm = st.wMonth;
    int d = st.wDay;
#endif

#ifdef LINUX
    time_t nSeconds;
    struct tm * pTM;

    time(&nSeconds); // 同 nSeconds = time(NULL);
    pTM = localtime(&nSeconds);

    int h = pTM->tm_hour;
    int m = pTM->tm_min;
    int s = pTM->tm_sec;

    int y = pTM->tm_year+1900;
    int mm = pTM->tm_mon + 1;
    int d  = pTM->tm_mday;
#endif

    if (y == 2019 && mm < 6)
        return true;
    else
    {
        printf("The version is too old.\n");
        return false;
    }
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

//读取INI
char *get_string_from_ini(char *title, char *key, char *filename)
{
    FILE *fp;
    char szLine[1024];
    static char tmpstr[1024];
    unsigned char rtnval;
    int i = 0;
    int flag = 0;
    char *tmp;

    if ((fp = fopen(filename, "r")) == NULL)
    {
        perror("fopen()");
        return NULL;
    }

    while (!feof(fp))
    {
        rtnval = fgetc(fp);
        if (rtnval == EOF)
        {
            break;
        }
        else
        {
            if (rtnval > 128)
            {
                szLine[i++] = '\0';
                break;
            }
            else
            {
                szLine[i++] = rtnval;
            }
        }

        if (rtnval == '\n')
        {
            szLine[--i] = '\n';
            i = 0;
            tmp = strchr(szLine, '=');

            if ((tmp != NULL) && (flag == 1))
            {
                if (strstr(szLine, key) != NULL)
                {
                    //comment
                    if ('#' == szLine[0]);
                    else if ('/' == szLine[0] && '/' == szLine[1]);
                    else
                    {
                        //local key position
                        char *enter = strchr(tmp + 1, '\n');
                        enter[0] = '\0';
                        strcpy(tmpstr, tmp + 1);
                        fclose(fp);
                        return tmpstr;
                    }
                }
            }
            else
            {
                strcpy(tmpstr, "[");
                strcat(tmpstr, title);
                strcat(tmpstr, "]");

                if (strncmp(tmpstr, szLine, strlen(tmpstr)) == 0)
                {
                    //encounter title
                    flag = 1;
                }
            }
        }
    }

    if (tmp == 0)
    {
        tmp = strchr(szLine, '=');
        strcpy(tmpstr, tmp + 1);
        fclose(fp);
        return tmpstr;
    }
    else
    {
        fclose(fp);
        return "";
    }

}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

int get_int_from_ini(char *title, char *key, char *filename, int & nRetVal)
{
    char * szRetVal = get_string_from_ini(title, key, filename);
    if (NULL == szRetVal)
    {
        return -1;
    }
    else
    {
        nRetVal = atoi(szRetVal);
        return 0;
    }
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

//读取INI
void String2File(const char * szFileName, const char * key, const char * szString, double dwTime)
{
    if (NULL == szFileName || NULL == key || NULL == szString )
    {
        return ;
    }

    FILE *fp = NULL;
    char  fileName[1024];
    strcpy(fileName, szFileName);
    fp=fopen(fileName, "a");
    fprintf(fp, "%f:%s=%s\n", dwTime, key, szString); /*向所建文件写一字符串*/
    fclose(fp);
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

void Number2File(const char * szFileName, const char * key, double dwVal, double dwTime)
{
    if (NULL == szFileName || NULL == key )
    {
        return ;
    }

    FILE *fp = NULL;
    char  fileName[1024];
    strcpy(fileName, szFileName);
    fp=fopen(fileName, "a");
    fprintf(fp, "%f:%s=%f\n", dwTime, key, dwVal); /*向所建文件写一字符串*/
    fclose(fp);
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

//记录日志
static inline void printString(const char * szFileName, const char * key, const char * szString, double dwTime)
{
    //double dwTime = get_tick_count();

    if (NULL == szFileName || NULL == key || NULL == szString )
    {
        return ;
    }

    int nVal = 0;
    int nRet = get_int_from_ini("C_SWITCH", "debug", "cfg/ETrader.ini", nVal);
    if(1 == nVal)
    {
        char  fileName[1024];
        sprintf(fileName, "log/c_rec_%s.log", szFileName);

        String2File(fileName, key, szString, dwTime);
    }

    nRet = get_int_from_ini("C_SWITCH", "detail", "cfg/ETrader.ini", nVal);
    if(1 == nVal)
    {
        String2File("log/c_rec_all.log", key, szString, dwTime);
    }
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

static inline void printNumber(const char * szFileName, const char * key, double nData, double dwTime)
{
    //double dwTime = get_tick_count();

    if (NULL == szFileName || NULL == key)
    {
        return ;
    }
    int nVal = 0;
    int nRet = get_int_from_ini("C_SWITCH", "debug", "cfg/ETrader.ini", nVal);
    if(1 == nVal)
    {
        char  fileName[1024];
        sprintf(fileName, "log/c_rec_%s.log", szFileName);

        Number2File(fileName, key, nData, dwTime);
    }

    nRet = get_int_from_ini("C_SWITCH", "detail", "cfg/ETrader.ini", nVal);
    if(1 == nVal)
    {
        Number2File("log/c_rec_all.log", key, nData, dwTime);
    }
}

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

#endif /* MyTools_H */
