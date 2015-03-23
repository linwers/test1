/* Copyright 2004 - 2009 The MathWorks, Inc. */

/* Header file wit the definition of des_rng_param structure.
This definition moved here from des_rand_gen_api.h because we
faced multiple issues with the having the declarations of the rng
functions in that file being included from different locations (gen code, sldes.dll,simevents.dll)
Also, there was a conflict between the rng objects being compiled/linked with MT and MD options on windows.
*/

/* generic structure containing parameter information and state vector(s) */
#ifndef _des_rand_gen_def_h_
#define _des_rand_gen_def_h_

struct des_rng_param_T;

typedef struct des_rng_param_T des_rng_param;

struct des_rng_param_T
{    
    real64_T *unifState; /* state vector for uniform distribution */
    uint32_T *normState; /* state vector for normal distribution */
    void *pt2Param; /* parameter structure; see below for definition about 
                     * different distributions
                     */
    void (*pt2FuncRandGen)(real64_T *, des_rng_param *); /* function pointer for 
                                                          * random nubmer generation 
                                                          */
    void (*pt2FuncErr)(const char* msg);                 /* function pointer for 
                                                          * printing error message
                                                          */
};

#endif

