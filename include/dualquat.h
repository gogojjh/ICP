#ifndef DUALQUAT_H
#define DUALQUAT_H
#include <iostream>

template <typename T>
class Quat {
  public:
    union {
      T data[4];
      struct {
        T w; T x; T y; T z;
      };
    };

    Quat(){};
    Quat(T w, T x, T y, T z) :
      w(w), x(x), y(y), z(z) {}

    Quat& operator+=(const Quat& rhs) {
      this->w += rhs.w; this->x += rhs.x; this->y += rhs.y; this->z += rhs.z;
      return *this;
    }

    friend Quat operator+(Quat lhs, const Quat& rhs) {
      lhs += rhs;
      return lhs;
    }

    Quat operator-() const {
      return Quat(-this->w, -this->x, -this->y, -this->z);
    }

    Quat& operator-=(const Quat& rhs) {
      *this += -rhs;
      return *this;
    }

    friend Quat operator-(Quat lhs, const Quat& rhs) {
      lhs -= rhs;
      return lhs;
    }

    Quat& operator*=(const Quat& rhs) {
      T w = this->w*rhs.w - this->x*rhs.x - this->y*rhs.y - this->z*rhs.z;
      T x = this->x*rhs.w + this->w*rhs.x - this->z*rhs.y + this->y*rhs.z;
      T y = this->y*rhs.w + this->z*rhs.x + this->w*rhs.y - this->x*rhs.z;
      T z = this->z*rhs.w - this->y*rhs.x + this->x*rhs.y + this->w*rhs.z;
      this->w = w; this->x = x; this->y = y; this->z = z;
      return *this;
    }

    friend Quat operator*(Quat lhs, const Quat& rhs) {
      lhs *= rhs;
      return lhs;
    }

    Quat& operator/=(const Quat& rhs) {
      T denom = rhs.magnitude();
      denom *= denom;
      T w = (this->w*rhs.w + this->x*rhs.x + this->y*rhs.y + this->z*rhs.z)/denom;
      T x = (this->x*rhs.w - this->w*rhs.x - this->z*rhs.y + this->y*rhs.z)/denom;
      T y = (this->y*rhs.w + this->z*rhs.x - this->w*rhs.y - this->x*rhs.z)/denom;
      T z = (this->z*rhs.w - this->y*rhs.x + this->x*rhs.y - this->w*rhs.z)/denom;
      this->w = w; this->x = x; this->y = y; this->z = z;
      return *this;
    }

    friend Quat operator/(Quat lhs, const Quat& rhs) {
      lhs /= rhs;
      return lhs;
    }

    Quat& conjugate();

    T magnitude() const;

    void normalize();

    friend std::ostream& operator<<(std::ostream& os, const Quat& rhs) {
      return os << rhs.w << " + " << rhs.x << "i + " << rhs.y << "j + " <<
        rhs.z << "k";
    }
};

template <typename T>
inline bool operator==(const Quat<T>& lhs, const Quat<T>& rhs) {
  return (lhs.w == rhs.w) && (lhs.x == rhs.x) &&
    (lhs.y == rhs.y) && (lhs.z == rhs.z);
}

template <typename T>
inline bool operator!=(const Quat<T>& lhs, const Quat<T>& rhs) {
  return !(lhs == rhs);
}

template <typename T>
class DualQuat {
  public:
    Quat<T> r;
    Quat<T> d;

    DualQuat() {}
    DualQuat(Quat<T> r, Quat<T> d) : r(r), d(d) {}

    DualQuat& operator+=(const DualQuat& rhs) {
      this->r += rhs.r;
      this->d += rhs.d;
      return *this;
    }

    friend DualQuat operator+(DualQuat lhs, const DualQuat& rhs) {
      lhs += rhs;
      return lhs;
    }

    DualQuat operator-() const {
      return DualQuat(-r, -d);
    }

    DualQuat& operator-=(const DualQuat& rhs) {
      *this += -rhs;
      return *this;
    }

    friend DualQuat operator-(DualQuat lhs, const DualQuat& rhs) {
      lhs -= rhs;
      return lhs;
    }

    DualQuat& operator*=(const DualQuat& rhs) {
      Quat<T> r = this->r * rhs.r;
      this->d = this->r * rhs.d + this->d * rhs.r;
      this->r = r;
      return *this;
    }

    friend DualQuat operator*(DualQuat lhs, const DualQuat& rhs) {
      lhs *= rhs;
      return lhs;
    }

    DualQuat& conjugate();

    T realMagnitude() const;

    void normalize();

    friend std::ostream& operator<<(std::ostream& os, const DualQuat& rhs) {
      return os << "(" << rhs.r << ") + (" << rhs.d << ")e";
    }
};

template <typename T>
inline bool operator==(const DualQuat<T>& lhs, const DualQuat<T>& rhs) {
  return (lhs.r == rhs.r) && (lhs.d == rhs.d);
}

template <typename T>
inline bool operator!=(const DualQuat<T>& lhs, const DualQuat<T>& rhs) {
  return !(lhs == rhs);
}

#endif // DUALQUAT_H
