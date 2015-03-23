/*
 *des_cg_interface.h    
 */
/* Copyright 2003-2009 The MathWorks, Inc. */


#ifndef __des_cg_defs_h__
#define __des_cg_defs_h__

#define NOT_EXIST -1 

 
/* RTSeCfgPr_T is the struct tag for the Configuration Parameters 
*/
typedef struct RTSeCfgPr_T
{
     int exeOrd; /*execution order: randomization or arbitrary*/
     int randomizationSeed; /*seed for randomization */
     int maxSimulBlkEvts;
     int maxSimulMdlEvts;
}RTSeCfgPr;

/* AttributeDef_T is the struct tag for Attribute Definition for the 
entity list created at the beginning of the simulation.
*/
typedef struct AttributeDef_T
{
    const char* name;
    size_t  idxDesDataInfo;
}AttributeDef;

/* BParams_T is the struct tag for block parameters */
typedef struct BParams_T
{
     const char* value; /* use constThis structure could change as the design for emitter evolves.*/
}BParams;

/* InSeConn_T is the struct tag the Entity input ports */
typedef struct InSeConn_T
{
    double otherBlkID; 
    int otherPrtID; 
}InSeConn;

/* OutSeConn_T is the struct tag the Entity output ports */
typedef struct OutSeConn_T
{
    double otherBlkID; 
    int otherPrtID; 
}OutSeConn;

/* InSlConn_T is the struct tag the simulink signal input ports*/
typedef struct InSlConn_T
{
    int index; /*for solver interface obj index*/
    int idxInDesDataInfo;
}InSlConn;


/* OutSlConn_T is the struct tag the simulink signal output ports */
typedef struct OutSlConn_T
{
    int index; /*for solver interface obj index*/
    int idxInDesDataInfo;
}OutSlConn;

/* DesDataInfoSer_T is the struct tag for storing DesDataInfo */
typedef struct DesDataInfoSer_T
{
    int_T width; 
    int_T numDims;
    int_T startIdx_DimsArray; /* the idx of the first dim in the dims container*/
    int_T complex;
}DesDataInfoSer;

/* DesDataDims_T is the struct tag for storing dimension info of DesDataInfo */
typedef struct DesDataDims_T
{
    int_T dim;
}DesDataDims;


typedef struct RTSeNode_T
{
     double bId; /* block id, which is a handle*/
     int bType;
     const char* bName;
     size_t idxBParams; 
     size_t numBParams;
     BParams * bParams;
     size_t idxInSeConn;
     size_t numInSeConn;
     InSeConn * inSeConn;
     size_t idxOutSeConn;
     size_t numOutSeConn;
     OutSeConn *outSeConn;
     size_t idxInSlConn;
     size_t numInSlConn;
     InSlConn * inSlConn;
     size_t idxOutSlConn; 
     size_t numOutSlConn; 
     OutSlConn * outSlConn; 
}RTSeNode;

#endif /* des_cg_defs_h */

