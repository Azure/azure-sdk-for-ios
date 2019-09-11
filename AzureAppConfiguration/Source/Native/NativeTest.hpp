//
//  NativeTest.hpp
//  AzureAppConfiguration
//
//  Created by Travis Prescott on 9/10/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#ifndef NativeTest_hpp
#define NativeTest_hpp

#include <stdio.h>

class NativeTest {
public:
    NativeTest(int);
    int getVal();
private:
    int m_Int;
};

#endif /* NativeTest_hpp */
