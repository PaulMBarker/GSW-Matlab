function cabbeling = gsw_cabbeling(SA,CT,p)

% gsw_cabbeling                                       cabbeling coefficient 
%                                                        (75-term equation)
%==========================================================================
%
% USAGE:  
%  cabbeling = gsw_cabbeling(SA,CT,p)
%
% DESCRIPTION:
%  Calculates the cabbeling coefficient of seawater with respect to  
%  Conservative Temperature.  This function uses the computationally-
%  efficient expression for specific volume in terms of SA, CT and p
%  (Roquet et al., 2015).
%   
%  Note that the 75-term equation has been fitted in a restricted range of 
%  parameter space, and is most accurate inside the "oceanographic funnel" 
%  described in McDougall et al. (2003).  The GSW library function 
%  "gsw_infunnel(SA,CT,p)" is avaialble to be used if one wants to test if 
%  some of one's data lies outside this "funnel".  
%
% INPUT:
%  SA  =  Absolute Salinity                                        [ g/kg ]
%  CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
%  p   =  sea pressure                                             [ dbar ]
%         ( i.e. absolute pressure - 10.1325 dbar )
%
%  SA & CT need to have the same dimensions.
%  p may have dimensions 1x1 or Mx1 or 1xN or MxN, where SA & CT are MxN.
%
% OUTPUT:
%  cabbeling  =  cabbeling coefficient with respect to            [ 1/K^2 ]
%                Conservative Temperature.                    
%
% AUTHOR: 
%  Trevor McDougall and Paul Barker                    [ help@teos-10.org ]   
%
% VERSION NUMBER: 3.06.12 (25th May, 2020)
%
% REFERENCES:
%  IOC, SCOR and IAPSO, 2010: The international thermodynamic equation of 
%   seawater - 2010: Calculation and use of thermodynamic properties.  
%   Intergovernmental Oceanographic Commission, Manuals and Guides No. 56,
%   UNESCO (English), 196 pp.  Available from http://www.TEOS-10.org
%    See Eqns. (3.9.2) and (P.4) of this TEOS-10 manual.
%
%  McDougall, T.J., D.R. Jackett, D.G. Wright and R. Feistel, 2003: 
%   Accurate and computationally efficient algorithms for potential 
%   temperature and density of seawater.  J. Atmosph. Ocean. Tech., 20,
%   pp. 730-741.
%
%  Roquet, F., G. Madec, T.J. McDougall, P.M. Barker, 2015: Accurate
%   polynomial expressions for the density and specifc volume of seawater
%   using the TEOS-10 standard. Ocean Modelling., 90, pp. 29-43.
%
%  The software is available from http://www.TEOS-10.org
%
%==========================================================================

%--------------------------------------------------------------------------
% Check variables and resize if necessary
%--------------------------------------------------------------------------

if ~(nargin == 3)
   error('gsw_cabbeling:  Requires three inputs')
end 

[ms,ns] = size(SA);
[mt,nt] = size(CT);
[mp,np] = size(p);

if (mt ~= ms | nt ~= ns)
    error('gsw_cabbeling: SA and CT must have same dimensions')
end

if (mp == 1) & (np == 1)              % p is a scalar - fill to size of SA
    p = p*ones(size(SA));
elseif (ns == np) & (mp == 1)         % p is row vector,
    p = p(ones(1,ms), :);              % copy down each column.
elseif (ms == mp) & (np == 1)         % p is column vector,
    p = p(:,ones(1,ns));               % copy across each row.
elseif (ns == mp) & (np == 1)          % p is a transposed row vector,
    p = p.';                              % transposed then
    p = p(ones(1,ms), :);                % copy down each column.
elseif (ms == mp) & (ns == np)
    % ok
else
    error('gsw_cabbeling: Inputs array dimensions arguments do not agree')
end 

if ms == 1
    SA = SA.';
    CT = CT.';
    p = p.';
    transposed = 1;
else
    transposed = 0;
end

%--------------------------------------------------------------------------
% Start of the calculation
%--------------------------------------------------------------------------

% This line ensures that SA is non-negative.
SA(SA < 0) = 0;

[v_SA, v_CT, dummy] = gsw_specvol_first_derivatives(SA,CT,p);
     
[v_SA_SA, v_SA_CT, v_CT_CT, dummy, dummy] = gsw_specvol_second_derivatives(SA,CT,p);

rho = gsw_rho(SA,CT,p);
     
alpha_CT = rho.*(v_CT_CT - rho.*v_CT.^2);

alpha_SA = rho.*(v_SA_CT - rho.*v_SA.*v_CT);

beta_SA = -rho.*(v_SA_SA - rho.*v_SA.^2);

alpha_on_beta = gsw_alpha_on_beta(SA,CT,p);

cabbeling = alpha_CT + alpha_on_beta.*(2.*alpha_SA - alpha_on_beta.*beta_SA);

if transposed
    cabbeling = cabbeling.';
end

end
