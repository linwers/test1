function  des_pmioporthelp(blkhandle)
% MECH_PMIOPORTHELP Points Help browser to the HTML help file corresponding
%                   to the SimEvents Connection Port block.
%
%                    This function is registered in the SimEvents compiler
%                    as the Help callback for Connection Port block in the
%                    SimEvents domain.  The argument 'blkhandle' contains
%                    the passed block handle of the original
%                    Connection Port block issuing the callback.
%   Copyright 2004 The MathWorks, Inc.

helpview(simeventsbhelp)