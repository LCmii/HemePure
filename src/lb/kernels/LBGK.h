// This file is part of HemeLB and is Copyright (C)
// the HemeLB team and/or their institutions, as detailed in the
// file AUTHORS. This software is provided under the terms of the
// license in the file LICENSE.

#ifndef HEMELB_LB_KERNELS_LBGK_H
#define HEMELB_LB_KERNELS_LBGK_H

#include <cstdlib>
#include "lb/HFunction.h"
#include "util/utilityFunctions.h"
#include "lb/kernels/BaseKernel.h"

#if defined(HEMELB_USE_AVX2) || defined(HEMELB_USE_AVX512)
#include <immintrin.h>
#endif

namespace hemelb
{
	namespace lb
	{
		namespace kernels
		{
			template<class LatticeType>
				class LBGK : public BaseKernel<LBGK<LatticeType>, LatticeType>
			{
				public:
					LBGK(InitParams& initParams)
					{
					}

					inline void DoCalculateDensityMomentumFeq(HydroVars<LBGK<LatticeType> >& hydroVars, site_t index)
					{
						LatticeType::CalculateDensityMomentumFEq(hydroVars.f,
								hydroVars.density,
								hydroVars.momentum.x,
								hydroVars.momentum.y,
								hydroVars.momentum.z,
								hydroVars.velocity.x,
								hydroVars.velocity.y,
								hydroVars.velocity.z,
								hydroVars.f_eq.f);

#if defined(HEMELB_USE_AVX512)
						// AVX512 optimized version - process 8 doubles at once
						Direction numVect8 = ((LatticeType::NUMVECTORS >> 3) << 3);
						for (Direction ii = 0; ii < numVect8; ii += 8)
						{
							const __m512d f = _mm512_loadu_pd(&hydroVars.f[ii]);
							const __m512d f_eq = _mm512_loadu_pd(&hydroVars.f_eq.f[ii]);
							_mm512_storeu_pd(&hydroVars.f_neq.f[ii], _mm512_sub_pd(f, f_eq));
						}
						// Handle remaining elements
						for (Direction ii = numVect8; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#elif defined(HEMELB_USE_AVX2)
						// AVX2 optimized version - process 4 doubles at once
						Direction numVect4 = ((LatticeType::NUMVECTORS >> 2) << 2);
						for (Direction ii = 0; ii < numVect4; ii += 4)
						{
							const __m256d f = _mm256_loadu_pd(&hydroVars.f[ii]);
							const __m256d f_eq = _mm256_loadu_pd(&hydroVars.f_eq.f[ii]);
							_mm256_storeu_pd(&hydroVars.f_neq.f[ii], _mm256_sub_pd(f, f_eq));
						}
						// Handle remaining elements
						for (Direction ii = numVect4; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#else
						for (unsigned int ii = 0; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#endif
					}

					inline void DoCalculateFeq(HydroVars<LBGK>& hydroVars, site_t index)
					{
						LatticeType::CalculateFeq(hydroVars.density,
								hydroVars.momentum.x,
								hydroVars.momentum.y,
								hydroVars.momentum.z,
								hydroVars.f_eq.f);

#if defined(HEMELB_USE_AVX512)
						// AVX512 optimized version
						Direction numVect8 = ((LatticeType::NUMVECTORS >> 3) << 3);
						for (Direction ii = 0; ii < numVect8; ii += 8)
						{
							const __m512d f = _mm512_loadu_pd(&hydroVars.f[ii]);
							const __m512d f_eq = _mm512_loadu_pd(&hydroVars.f_eq.f[ii]);
							_mm512_storeu_pd(&hydroVars.f_neq.f[ii], _mm512_sub_pd(f, f_eq));
						}
						for (Direction ii = numVect8; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#elif defined(HEMELB_USE_AVX2)
						// AVX2 optimized version
						Direction numVect4 = ((LatticeType::NUMVECTORS >> 2) << 2);
						for (Direction ii = 0; ii < numVect4; ii += 4)
						{
							const __m256d f = _mm256_loadu_pd(&hydroVars.f[ii]);
							const __m256d f_eq = _mm256_loadu_pd(&hydroVars.f_eq.f[ii]);
							_mm256_storeu_pd(&hydroVars.f_neq.f[ii], _mm256_sub_pd(f, f_eq));
						}
						for (Direction ii = numVect4; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#else
						for (unsigned int ii = 0; ii < LatticeType::NUMVECTORS; ++ii)
						{
							hydroVars.f_neq.f[ii] = hydroVars.f[ii] - hydroVars.f_eq.f[ii];
						}
#endif
					}

#if defined(HEMELB_USE_AVX512)
					inline void DoCollide(const LbmParameters* const lbmParams, HydroVars<LBGK>& hydroVars)
					{
						// AVX512 optimized collision - process 8 directions at once
						const __m512d omega_vec = _mm512_set1_pd(lbmParams->GetOmega());
						Direction numVect8 = ((LatticeType::NUMVECTORS >> 3) << 3);

						for (Direction direction = 0; direction < numVect8; direction += 8)
						{
							// Prefetch next block
							if (direction + 8 < numVect8)
							{
								_mm_prefetch(&hydroVars.f[direction + 8], _MM_HINT_T0);
								_mm_prefetch(&hydroVars.f_neq.f[direction + 8], _MM_HINT_T0);
							}

							const __m512d f = _mm512_loadu_pd(&hydroVars.f[direction]);
							const __m512d f_neq = _mm512_loadu_pd(&hydroVars.f_neq.f[direction]);
							const __m512d f_neq_omega = _mm512_mul_pd(f_neq, omega_vec);
							const __m512d f_post = _mm512_add_pd(f, f_neq_omega);
							_mm512_storeu_pd(&hydroVars.fPostCollision.f[direction], f_post);
						}

						// Handle remaining directions (1-3 for D3Q19)
						for (Direction direction = numVect8; direction < LatticeType::NUMVECTORS; ++direction)
						{
							hydroVars.SetFPostCollision(direction,
									hydroVars.f[direction]
									+ hydroVars.f_neq.f[direction] * lbmParams->GetOmega());
						}
					}
#elif defined(HEMELB_USE_AVX2)
					inline void DoCollide(const LbmParameters* const lbmParams, HydroVars<LBGK>& hydroVars)
					{
						// AVX2 optimized collision - process 4 directions at once
						const __m256d omega_vec = _mm256_set1_pd(lbmParams->GetOmega());
						Direction numVect4 = ((LatticeType::NUMVECTORS >> 2) << 2);

						for (Direction direction = 0; direction < numVect4; direction += 4)
						{
							// Prefetch next block
							if (direction + 4 < numVect4)
							{
								_mm_prefetch(&hydroVars.f[direction + 4], _MM_HINT_T0);
								_mm_prefetch(&hydroVars.f_neq.f[direction + 4], _MM_HINT_T0);
							}

							const __m256d f = _mm256_loadu_pd(&hydroVars.f[direction]);
							const __m256d f_neq = _mm256_loadu_pd(&hydroVars.f_neq.f[direction]);
							const __m256d f_neq_omega = _mm256_mul_pd(f_neq, omega_vec);
							const __m256d f_post = _mm256_add_pd(f, f_neq_omega);
							_mm256_storeu_pd(&hydroVars.fPostCollision.f[direction], f_post);
						}

						// Handle remaining directions
						for (Direction direction = numVect4; direction < LatticeType::NUMVECTORS; ++direction)
						{
							hydroVars.SetFPostCollision(direction,
									hydroVars.f[direction]
									+ hydroVars.f_neq.f[direction] * lbmParams->GetOmega());
						}
					}
#else
					inline void DoCollide(const LbmParameters* const lbmParams, HydroVars<LBGK>& hydroVars)
					{
						for (Direction direction = 0; direction < LatticeType::NUMVECTORS; ++direction)
						{
							hydroVars.SetFPostCollision(direction,
									hydroVars.f[direction]
									+ hydroVars.f_neq.f[direction] * lbmParams->GetOmega());
						}
					}
#endif

			};
		}
	}
}

#endif /* HEMELB_LB_KERNELS_LBGK_H */