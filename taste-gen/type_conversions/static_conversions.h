#ifndef __ESROCOS_KINGEN_TASTE_STATICCONVERSIONS__
#define __ESROCOS_KINGEN_TASTE_STATICCONVERSIONS__

#include <ilk/eigen/core-types.h>

namespace internal {

struct Quaternion
{
    double data[4];
    double& w() { return data[0]; }
    double& x() { return data[1]; }
    double& y() { return data[2]; }
    double& z() { return data[3]; }
    const double& w() const { return data[0]; }
    const double& x() const { return data[1]; }
    const double& y() const { return data[2]; }
    const double& z() const { return data[3]; }
};



template<typename Derived>
void __quat2rot(const Quaternion &q, Derived& R)
{
     R(0, 0) = -1.0 + 2.0 * (q.w() * q.w()) + 2.0 * (q.x() * q.x());
     R(1, 1) = -1.0 + 2.0 * (q.w() * q.w()) + 2.0 * (q.y() * q.y());
     R(2, 2) = -1.0 + 2.0 * (q.w() * q.w()) + 2.0 * (q.z() * q.z());
     R(0, 1) = 2.0 * (q.x() * q.y() + q.w() * q.z());
     R(0, 2) = 2.0 * (q.x() * q.z() - q.w() * q.y());
     R(1, 0) = 2.0 * (q.x() * q.y() - q.w() * q.z());
     R(1, 2) = 2.0 * (q.y() * q.z() + q.w() * q.x());
     R(2, 0) = 2.0 * (q.x() * q.z() + q.w() * q.y());
     R(2, 1) = 2.0 * (q.y() * q.z() - q.w() * q.x());
}

template<typename Derived>
void __rot2quat(const Derived& R, Quaternion& quat)
{
     double tr = R.trace();
     double sqrt_tr;

     if (tr > 1e-06)
     {
         sqrt_tr = sqrt(R.trace() + 1);
         quat.w() = 0.5*sqrt_tr;
         quat.x() = (R(1,2) - R(2,1))/(2.0*sqrt_tr);
         quat.y() = (R(2,0) - R(0,2))/(2.0*sqrt_tr);
         quat.z() = (R(0,1) - R(1,0))/(2.0*sqrt_tr);
     }
     else  if ((R(1,1) > R(0,0)) && (R(1,1) > R(2,2)))
     {
         // max value at R(1,1)
         sqrt_tr = sqrt(R(1,1) - R(0,0) - R(2,2) + 1.0 );

         quat.y() = 0.5*sqrt_tr;

         if ( sqrt_tr > 1e-06 ) sqrt_tr = 0.5/sqrt_tr;


         quat.w() = (R(2, 0) - R(0, 2))*sqrt_tr;
         quat.x() = (R(0, 1) + R(1, 0))*sqrt_tr;
         quat.z() = (R(1, 2) + R(2, 1))*sqrt_tr;

     }
     else if (R(2,2) > R(0,0))
     {
         // max value at R(2,2)
         sqrt_tr = sqrt(R(2,2) - R(0,0) - R(1,1) + 1.0 );

         quat.z() = 0.5*sqrt_tr;

         if ( sqrt_tr > 1e-06 ) sqrt_tr = 0.5/sqrt_tr;

         quat.w() = (R(0, 1) - R(1, 0))*sqrt_tr;
         quat.x() = (R(2, 0) + R(0, 2))*sqrt_tr;
         quat.y() = (R(1, 2) + R(2, 1))*sqrt_tr;
     }
     else {
         // max value at dcm(0,0)
         sqrt_tr = sqrt(R(0,0) - R(1,1) - R(2,2) + 1.0 );

         quat.x() = 0.5*sqrt_tr;

         if ( sqrt_tr > 1e-06 ) sqrt_tr = 0.5/sqrt_tr;

         quat.w() = (R(1, 2) - R(2, 1))*sqrt_tr;
         quat.y() = (R(0, 1) + R(1, 0))*sqrt_tr;
         quat.z() = (R(2, 0) + R(0, 2))*sqrt_tr;
     }
}

}

void rot2quat(const kul::rot_m_t &R, internal::Quaternion& quat)
{
    internal::__rot2quat(R, quat);
}
void rot2quat(const kul::rot_m_v R, internal::Quaternion& quat)
{
    internal::__rot2quat(R, quat);
}
void quat2rot(const internal::Quaternion &q, kul::rot_m_t &R)
{
    internal::__quat2rot(q, R);
}
void quat2rot(const internal::Quaternion &q, kul::rot_m_v R)
{
    internal::__quat2rot(q, R);
}



#endif
