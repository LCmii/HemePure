#!/bin/bash
echo -e "\n🚀 Building PARMETIS..."
  cd src
  FOLDER=build_PP_PARMETIS
  rm -rf $FOLDER && mkdir $FOLDER && cd $FOLDER

cmake .. \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DHEMELB_USE_GMYPLUS=OFF \
  -DHEMELB_USE_MPI_WIN=OFF \
  -DHEMELB_USE_SSE3=ON \
  -DHEMELB_USE_AVX2=ON \
  -DHEMELB_USE_PARMETIS=ON 


  make -j8
  cd ../../
  echo "✅ HemePure build_PP_PARMETIS done"
