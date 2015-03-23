/*
 *des_cg_interface.h    
 */


#ifndef des_cg_interface_h
#define des_cg_interface_h


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

    extern    char* simevents_getNextEngineHitTime(const char* mdlname, real_T slTimeNow, real_T* nextTimeVar, boolean_T incFlag);

    extern    char* simevents_setupRTEngine(const char* modelName, 
                        double            startTime,
		                double            endTime,
					    RTSeCfgPr*        cfgSet,
                        RTSeNode*         blocks,
                        size_t            numBlocks,
                        BParams*          bParams,
                        InSlConn*         inSlConns,
                        OutSlConn*        outSlConns,
                        InSeConn*         inSeConns,
                        OutSeConn*        outSeConns,
                        size_t            numAttribs,
                        AttributeDef*     attributeDefs,
                        size_t            numDataInfos,
                        DesDataInfoSer*   desDataInfos,
                        DesDataDims*      desDataDims);
    

    extern    char* simevents_bindSolvObjs(const char* mdlname);

    extern    char* simevents_edInPortUpdate(const char* mdlname,real_T index, real_T *value, real_T time);

    extern    char* simevents_edICInPortUpdate(const char* mdlname,real_T index, real_T *value, int_T size);

    extern    char* simevents_mrInPortUpdate(const char* mdlname,real_T index, real_T *value, real_T time);

    extern    void simevents_setFcnCallBackFcn(const char* mdlname,int index, void(*fcnCall)(void));

    extern    void simevents_setCecCallBackFcn(const char* mdlname,int index, void(*cecCall)(const real_T*, size_t dataSize, int_T ));

    extern    void simevents_exeterminate(const char* mdlName);

    extern void simevents_setIVCallBackFcn(const char* modelName,void(*ivBlkFcnPtr)(boolean_T compute));

    extern char* simevents_init_mr_internal_states(const char* modelName, real_T *icval, int_T mrIndex, int_T size);

    extern void simevents_setSigSrcCallBackFcn(const char* modelName, int32_T index, int32_T edSfunIndex,
                                           void(*sigSrcFcnPtr)(void));

#ifdef __cplusplus
}
#endif

#endif /* des_cg_interface_h */
