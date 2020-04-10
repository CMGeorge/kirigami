#ifndef KIRIGAMI2_EXPORT_H
#define KIRIGAMI2_EXPORT_H

#ifndef KIRIGAMI2_EXPORT
#  ifndef QT_STATIC
#    if defined(IS_KIRIGAMI2_EXPORT)
#      define KIRIGAMI2_EXPORT Q_DECL_EXPORT
#    else
#      define KIRIGAMI2_EXPORT Q_DECL_IMPORT
#    endif
#  else
#    define KIRIGAMI2_EXPORT
#  endif
#else
#define KIRIGAMI2_EXPORT
#endif


#endif // KIRIGAMI2_EXPORT_H
