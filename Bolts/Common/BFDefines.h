/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

#if __has_feature(objc_generics) || __has_extension(objc_generics)
#  define BF_GENERIC(type) <type>
#else
#  define BF_GENERIC(type)
#  define BFGenericType id
#endif
