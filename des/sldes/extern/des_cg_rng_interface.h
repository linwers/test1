/*
 *des_cg_interface.h    
 */


#ifndef des_cg_rng_interface_h
#define des_cg_rng_interface_h


/* Copyright 2004-2009 The MathWorks, Inc. */


#ifndef EXTERN_C

#ifdef __cplusplus
  #define EXTERN_C extern "C"
#else
  #define EXTERN_C extern
#endif

#endif

#include "des_cg_defs.h"
#ifdef __cplusplus
extern "C" {
#endif
    extern    void simevents_handleRNGErrorInCgExeEnv(const char *msg);

    extern    void  simevents_rngSetPBino(void* p, real64_T *pSuccess, real64_T *numTrial);
    extern    char* simevents_rngChkPBino(void* p);
    extern    void  simevents_rngInitBino(uint32_T *seed, void *p);
    extern    void  simevents_rngGenBino(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPUnif(void* p, real64_T *min, real64_T *max);
    extern    char* simevents_rngChkPUnif(void* p);
    extern    void  simevents_rngInitUnif(uint32_T *seed, void *p);
    extern    void  simevents_rngGenUnif(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPNorm(void* p, real64_T *mean,real64_T *std);
    extern    char* simevents_rngChkPNorm(void* p);
    extern    void  simevents_rngInitNorm(uint32_T *seed, void *p);
    extern    void  simevents_rngGenNorm(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPExp(void* p, real64_T *mean);
    extern    char* simevents_rngChkPExp(void* p);
    extern    void  simevents_rngInitExp(uint32_T *seed, void *p);
    extern    void  simevents_rngGenExp(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPWbl(void *p,real64_T *location,real64_T *scale,real64_T *shape,real64_T *shapeInv);
    extern    char* simevents_rngChkPWbl(void* p);
    extern    void  simevents_rngInitWbl(uint32_T *seed, void *p);
    extern    void  simevents_rngGenWbl(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPLogn(void *p,real64_T *location,real64_T *scale,real64_T *shape);
    extern    char* simevents_rngChkPLogn(void* p);
    extern    void  simevents_rngInitLogn(uint32_T *seed, void *p);
    extern    void  simevents_rngGenLogn(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPBern(void* p, real64_T *p1);
    extern    char* simevents_rngChkPBern(void* p);
    extern    void  simevents_rngInitBern(uint32_T *seed, void *p);
    extern    void  simevents_rngGenBern(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPGeo(void* p, real64_T *pSuccess,real64_T *invLog);
    extern    char* simevents_rngChkPGeo(void* p);
    extern    void  simevents_rngInitGeo(uint32_T *seed, void *p);
    extern    void  simevents_rngGenGeo(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPUnid(void* p, real64_T *min, real64_T *max, real64_T *numValue,real64_T *intervalSize);
    extern    char* simevents_rngChkPUnid(void* p);
    extern    void  simevents_rngInitUnid(uint32_T *seed, void *p);
    extern    void  simevents_rngGenUnid(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPDisc(void *p, real64_T *value, real64_T *prob, uint32_T numValue,real64_T *cdf);
    extern    char* simevents_rngChkPDisc(void* p);
    extern    void  simevents_rngInitDisc(uint32_T *seed, void *p);
    extern    void  simevents_rngGenDisc(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPGam(void *p, real64_T *location, real64_T *scale, real64_T *shape, real64_T *tempVar);
    extern    char* simevents_rngChkPGam(void* p);
    extern    void  simevents_rngInitGam(uint32_T *seed, void *p);
    extern    void  simevents_rngGenGam(real64_T *u, des_rng_param *p);
    extern    void  simevents_rngSetPGamStd(real64_T *shape, real64_T *tempVar);
    extern    void  simevents_rngGenGamStd(real64_T *u, real64_T *shape, real64_T *unifSVec, uint32_T *normSVec,real64_T *tempVar);

    extern    void  simevents_rngSetPLogl(void *p, real64_T *location, real64_T *scale, real64_T *expLoc);
    extern    char* simevents_rngChkPLogl(void* p);
    extern    void  simevents_rngInitLogl(uint32_T *seed, void *p);
    extern    void  simevents_rngGenLogl(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPPoiss(void *p, real64_T *mean);
    extern    char* simevents_rngChkPPoiss(void* p);
    extern    void  simevents_rngInitPoiss(uint32_T *seed, void *p);
    extern    void  simevents_rngGenPoiss(real64_T *u, des_rng_param *p);
    extern    real64_T simevents_rngGenPoissScalar(real64_T mean, real64_T *unifSVec, uint32_T *normSVec);

    extern    void  simevents_rngSetPBeta(void *p,  real64_T *min,real64_T *max, real64_T *shape1,real64_T *shape2, real64_T *tempVar);
    extern    char* simevents_rngChkPBeta(void* p);
    extern    void  simevents_rngInitBeta(uint32_T *seed, void *p);
    extern    void  simevents_rngGenBeta(real64_T *u, des_rng_param *p);

    extern    void  simevents_rngSetPCont(void *p,  real64_T *value,real64_T *cdf,uint32_T numValue);
    extern    char* simevents_rngChkPCont(void* p);
    extern    void  simevents_rngInitCont(uint32_T *seed, void *p);
    extern    void  simevents_rngGenCont(real64_T *u, des_rng_param *p); 

    extern    void  simevents_rngSetPTri(void *p,  real64_T *min,real64_T *max,real64_T *mode);
    extern    char* simevents_rngChkPTri(void* p);
    extern    void  simevents_rngInitTri(uint32_T *seed, void *p);
    extern    void  simevents_rngGenTri(real64_T *u, des_rng_param *p);

#ifdef __cplusplus
}
#endif

#endif /* des_cg_rng_interface_h */
