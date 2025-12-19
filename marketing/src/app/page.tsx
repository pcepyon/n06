"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";

// Intersection Observer Hook for scroll animations
function useInView(threshold = 0.1) {
  const ref = useRef<HTMLDivElement>(null);
  const [isInView, setIsInView] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsInView(true);
        }
      },
      { threshold }
    );

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, [threshold]);

  return { ref, isInView };
}

// Animated Counter
function Counter({ end, duration = 2000, suffix = "" }: { end: number; duration?: number; suffix?: string }) {
  const [count, setCount] = useState(0);
  const { ref, isInView } = useInView(0.5);

  useEffect(() => {
    if (!isInView) return;

    let startTime: number;
    const step = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / duration, 1);
      setCount(Math.floor(progress * end));
      if (progress < 1) {
        requestAnimationFrame(step);
      }
    };
    requestAnimationFrame(step);
  }, [isInView, end, duration]);

  return <span ref={ref}>{count}{suffix}</span>;
}

export default function Home() {
  const heroRef = useInView();
  const painRef = useInView();
  const solutionRef = useInView();
  const featuresRef = useInView();
  const journeyRef = useInView();
  const statsRef = useInView();
  const ctaRef = useInView();

  return (
    <div className="relative overflow-hidden bg-cream">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 glass">
        <div className="mx-auto max-w-6xl px-6 py-4">
          <div className="flex items-center justify-between">
            <a href="#" className="flex items-center gap-2">
              <div className="relative h-10 w-10 overflow-hidden rounded-xl shadow-soft">
                <Image
                  src="/images/logo.png"
                  alt="비우당 로고"
                  fill
                  className="object-cover"
                />
              </div>
              <span className="font-display text-xl font-semibold text-warm-gray-800">비우당</span>
            </a>
            <a
              href="#download"
              className="rounded-full bg-warm-gray-900 px-5 py-2.5 text-sm font-medium text-white transition-all hover:bg-warm-gray-800 hover:shadow-lg"
            >
              앱 다운로드
            </a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section
        ref={heroRef.ref}
        className="relative min-h-screen gradient-mesh noise-overlay"
      >
        {/* Floating Elements */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-20 left-[10%] h-64 w-64 rounded-full bg-mint-200/30 blur-3xl animate-pulse-soft" />
          <div className="absolute top-40 right-[15%] h-48 w-48 rounded-full bg-peach-200/40 blur-3xl animate-pulse-soft delay-300" />
          <div className="absolute bottom-32 left-[20%] h-56 w-56 rounded-full bg-mint-300/20 blur-3xl animate-pulse-soft delay-500" />
        </div>

        <div className="relative z-10 mx-auto flex min-h-screen max-w-6xl flex-col items-center justify-center px-6 pt-24 pb-16">
          <div className={`text-center ${heroRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            {/* Badge */}
            <div className="mb-8 inline-flex items-center gap-2 rounded-full bg-mint-100/80 px-4 py-2 text-sm font-medium text-mint-800 backdrop-blur-sm">
              <span className="flex h-2 w-2 rounded-full bg-mint-500 animate-pulse" />
              GLP-1 치료 전용 앱
            </div>

            {/* Main Headline */}
            <h1 className="mb-6 text-balance">
              <span className="block text-4xl font-light text-warm-gray-600 sm:text-5xl md:text-6xl">
                12주 후,
              </span>
              <span className="mt-2 block bg-gradient-to-r from-mint-600 via-mint-500 to-peach-400 bg-clip-text text-5xl font-bold text-transparent sm:text-6xl md:text-7xl animate-gradient">
                달라진 나를 만나보세요
              </span>
            </h1>

            {/* Subheadline */}
            <p className={`mx-auto max-w-2xl text-lg text-warm-gray-600 sm:text-xl ${heroRef.isInView ? 'animate-fade-up delay-200' : 'opacity-0'}`}>
              투여 알림이 오면 맞으면 돼요.<br className="hidden sm:block" />
              복잡한 스케줄 관리, 비우당이 알아서 해드릴게요.
            </p>

            {/* CTA Buttons */}
            <div className={`mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center ${heroRef.isInView ? 'animate-fade-up delay-300' : 'opacity-0'}`}>
              <a
                href="#download"
                className="group flex items-center gap-3 rounded-2xl bg-warm-gray-900 px-8 py-4 text-lg font-medium text-white shadow-soft-lg transition-all hover:bg-warm-gray-800 hover:scale-105"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                App Store 다운로드
                <span className="transition-transform group-hover:translate-x-1">→</span>
              </a>
              <a
                href="#features"
                className="flex items-center gap-2 rounded-2xl border-2 border-warm-gray-200 bg-white/50 px-8 py-4 text-lg font-medium text-warm-gray-700 backdrop-blur-sm transition-all hover:border-mint-300 hover:bg-white"
              >
                자세히 알아보기
              </a>
            </div>
          </div>

          {/* App Preview */}
          <div className={`mt-16 relative ${heroRef.isInView ? 'animate-fade-up delay-500' : 'opacity-0'}`}>
            <div className="relative mx-auto w-[280px] sm:w-[320px]">
              {/* Phone Frame with Image */}
              <div className="relative rounded-[3rem] bg-warm-gray-900 p-2 shadow-soft-lg">
                <div className="overflow-hidden rounded-[2.5rem] bg-cream">
                  <Image
                    src="/images/hero-app-mockup.png"
                    alt="비우당 앱 실행 화면"
                    width={320}
                    height={640}
                    className="h-full w-full object-cover"
                    priority
                  />
                </div>
              </div>

              {/* Floating Cards */}
              <div className="absolute -left-20 top-1/4 hidden lg:block animate-float-slow">
                <div className="rounded-xl bg-white p-3 shadow-soft-lg">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">🎉</span>
                    <div>
                      <p className="text-xs text-warm-gray-500">마일스톤 달성!</p>
                      <p className="text-sm font-semibold text-warm-gray-800">4주 연속 기록</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="absolute -right-16 bottom-1/3 hidden lg:block animate-float delay-300">
                <div className="rounded-xl bg-white p-3 shadow-soft-lg">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">💪</span>
                    <div>
                      <p className="text-xs text-warm-gray-500">이번 주</p>
                      <p className="text-sm font-semibold text-mint-600">-1.2kg</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Scroll Indicator */}
          <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
            <svg className="h-8 w-8 text-warm-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
            </svg>
          </div>
        </div>
      </section>

      {/* Pain Points Section */}
      <section
        ref={painRef.ref}
        className="relative bg-warm-gray-50 py-24 sm:py-32"
      >
        <div className="mx-auto max-w-6xl px-6">
          <div className={`text-center ${painRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <h2 className="text-3xl font-bold text-warm-gray-800 sm:text-4xl">
              혹시 이런 걱정, 하고 계신가요?
            </h2>
            <p className="mt-4 text-lg text-warm-gray-600">
              GLP-1 치료를 시작하면서 느끼는 불안, 당연한 거예요.
            </p>
          </div>

          <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {[
              {
                emoji: "😰",
                title: "주사가 두려워요",
                description: "자가 주사라니, 처음이라 어떻게 해야 할지 모르겠어요.",
                response: "처음엔 누구나 두려워요. 천천히 알려드릴게요.",
              },
              {
                emoji: "🤢",
                title: "부작용이 걱정돼요",
                description: "메스꺼움이나 구토가 생기면 어떡하죠?",
                response: "증상을 기록하고 의료진과 상담할 수 있게 도와드려요.",
              },
              {
                emoji: "😓",
                title: "또 실패할까 봐요",
                description: "다이어트 실패 경험이 많아서 자신이 없어요.",
                response: "이번엔 의지가 아닌 과학이 도와줘요.",
              },
              {
                emoji: "📅",
                title: "스케줄이 복잡해요",
                description: "용량 증량, 부위 순환... 기억하기 너무 어려워요.",
                response: "알림만 확인하면 돼요. 나머진 맡겨두세요.",
              },
              {
                emoji: "🏥",
                title: "병원에서 뭘 말해야 할지",
                description: "진료실에서 어떤 증상을 어떻게 설명해야 할지 모르겠어요.",
                response: "리포트가 대신 말해줄 거예요.",
              },
              {
                emoji: "😔",
                title: "혼자 하려니 외로워요",
                description: "주변에 같은 치료받는 사람이 없어서...",
                response: "비우당이 여정을 함께할게요.",
              },
            ].map((item, index) => (
              <div
                key={item.title}
                className={`group relative overflow-hidden rounded-3xl bg-white p-6 shadow-soft transition-all hover:shadow-soft-lg hover:-translate-y-1 ${painRef.isInView ? 'animate-fade-up' : 'opacity-0'
                  }`}
                style={{ animationDelay: `${index * 100}ms` }}
              >
                <span className="text-4xl">{item.emoji}</span>
                <h3 className="mt-4 text-xl font-semibold text-warm-gray-800">{item.title}</h3>
                <p className="mt-2 text-warm-gray-600">{item.description}</p>

                {/* Response on hover */}
                <div className="mt-4 rounded-xl bg-mint-50 p-3 opacity-0 transition-opacity group-hover:opacity-100">
                  <p className="text-sm font-medium text-mint-700">
                    → {item.response}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Solution Section */}
      <section
        ref={solutionRef.ref}
        id="solution"
        className="relative py-24 sm:py-32 overflow-hidden"
      >
        {/* Background Decoration */}
        <div className="absolute inset-0 gradient-mesh opacity-50" />

        <div className="relative mx-auto max-w-6xl px-6">
          <div className={`text-center ${solutionRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <div className="inline-flex items-center gap-2 rounded-full bg-mint-100 px-4 py-2 text-sm font-medium text-mint-800">
              <span className="flex h-2 w-2 rounded-full bg-mint-500" />
              비우당이 도와드릴게요
            </div>
            <h2 className="mt-6 text-3xl font-bold text-warm-gray-800 sm:text-4xl md:text-5xl">
              치료에만 집중하세요.<br />
              <span className="text-mint-600">나머진 맡겨두세요.</span>
            </h2>
          </div>

          <div className="mt-16 grid gap-8 lg:grid-cols-3">
            {[
              {
                icon: (
                  <svg className="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                ),
                title: "자동 스케줄 관리",
                description: "용량 증량, 투여일, 부위 순환까지. 알림만 확인하면 돼요.",
                gradient: "from-mint-400 to-mint-600",
              },
              {
                icon: (
                  <svg className="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                  </svg>
                ),
                title: "증상 기록 & 정보",
                description: "증상을 기록하고 의료진과 공유할 수 있어요. 일반적인 정보도 제공해요.",
                gradient: "from-peach-300 to-peach-500",
              },
              {
                icon: (
                  <svg className="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                ),
                title: "진행 상황 시각화",
                description: "내가 해내고 있다는 걸, 숫자와 그래프로 확인하세요.",
                gradient: "from-mint-500 to-sage-400",
              },
            ].map((item, index) => (
              <div
                key={item.title}
                className={`group relative overflow-hidden rounded-3xl bg-white p-8 shadow-soft-lg transition-all hover:-translate-y-2 ${solutionRef.isInView ? 'animate-fade-up' : 'opacity-0'
                  }`}
                style={{ animationDelay: `${index * 150}ms` }}
              >
                <div className={`inline-flex rounded-2xl bg-gradient-to-br ${item.gradient} p-4 text-white shadow-soft`}>
                  {item.icon}
                </div>
                <h3 className="mt-6 text-xl font-semibold text-warm-gray-800">{item.title}</h3>
                <p className="mt-3 text-warm-gray-600 leading-relaxed">{item.description}</p>

                {/* Decorative corner */}
                <div className={`absolute -bottom-10 -right-10 h-32 w-32 rounded-full bg-gradient-to-br ${item.gradient} opacity-10 transition-transform group-hover:scale-150`} />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section
        ref={featuresRef.ref}
        id="features"
        className="relative bg-warm-gray-900 py-24 sm:py-32 overflow-hidden"
      >
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-5">
          <svg className="h-full w-full" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="white" strokeWidth="1" />
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>

        <div className="relative mx-auto max-w-6xl px-6">
          <div className={`text-center ${featuresRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <h2 className="text-3xl font-bold text-white sm:text-4xl md:text-5xl">
              이런 기능을 제공해요
            </h2>
            <p className="mt-4 text-lg text-warm-gray-400">
              복잡한 건 비우당이, 당신은 치료에만 집중하세요.
            </p>
          </div>

          <div className="mt-16 space-y-24">
            {/* Feature 1 */}
            <div className={`flex flex-col items-center gap-12 lg:flex-row ${featuresRef.isInView ? 'animate-fade-up delay-200' : 'opacity-0'}`}>
              <div className="flex-1">
                <div className="inline-flex rounded-full bg-mint-500/20 px-4 py-2 text-sm font-medium text-mint-400">
                  투여 스케줄러
                </div>
                <h3 className="mt-4 text-2xl font-bold text-white sm:text-3xl">
                  다음 투여일, 잊어버려도 괜찮아요
                </h3>
                <p className="mt-4 text-warm-gray-400 leading-relaxed">
                  개인별 용량 증량 계획에 맞춰 자동으로 스케줄을 관리해요.
                  주사 부위 순환도 알아서 추천해 드리니, 알림이 오면 맞으면 돼요.
                </p>
                <ul className="mt-6 space-y-3">
                  {["용량별 자동 스케줄 생성", "주사 부위 순환 가이드", "맞춤형 리마인더 알림"].map((item) => (
                    <li key={item} className="flex items-center gap-3 text-warm-gray-300">
                      <svg className="h-5 w-5 text-mint-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
              <div className="flex-1">
                <div className="relative rounded-3xl bg-gradient-to-br from-warm-gray-800 to-warm-gray-900 p-8 shadow-soft-lg">
                  <div className="rounded-2xl bg-warm-gray-800/50 p-6">
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-warm-gray-400">이번 주 스케줄</span>
                      <span className="rounded-full bg-mint-500/20 px-3 py-1 text-xs font-medium text-mint-400">활성화</span>
                    </div>
                    <div className="mt-4 space-y-3">
                      {[
                        { day: "월", status: "완료", dose: "0.25mg" },
                        { day: "수", status: "오늘", dose: "0.25mg" },
                        { day: "금", status: "예정", dose: "0.5mg" },
                      ].map((item) => (
                        <div key={item.day} className={`flex items-center justify-between rounded-xl p-3 ${item.status === "오늘" ? "bg-mint-500/20 ring-1 ring-mint-500/50" : "bg-warm-gray-700/50"
                          }`}>
                          <div className="flex items-center gap-3">
                            <span className={`flex h-8 w-8 items-center justify-center rounded-lg text-sm font-medium ${item.status === "완료" ? "bg-mint-500 text-white" :
                              item.status === "오늘" ? "bg-mint-400 text-warm-gray-900" :
                                "bg-warm-gray-600 text-warm-gray-300"
                              }`}>
                              {item.day}
                            </span>
                            <span className={`text-sm ${item.status === "오늘" ? "text-mint-300" : "text-warm-gray-400"}`}>
                              {item.dose}
                            </span>
                          </div>
                          <span className={`text-xs ${item.status === "완료" ? "text-mint-400" :
                            item.status === "오늘" ? "text-mint-300 font-medium" :
                              "text-warm-gray-500"
                            }`}>
                            {item.status}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Feature 2 */}
            <div className={`flex flex-col items-center gap-12 lg:flex-row-reverse ${featuresRef.isInView ? 'animate-fade-up delay-400' : 'opacity-0'}`}>
              <div className="flex-1">
                <div className="inline-flex rounded-full bg-peach-400/20 px-4 py-2 text-sm font-medium text-peach-300">
                  증상 기록 & 의료진 공유
                </div>
                <h3 className="mt-4 text-2xl font-bold text-white sm:text-3xl">
                  증상을 기록하고<br />의료진과 공유하세요
                </h3>
                <p className="mt-4 text-warm-gray-400 leading-relaxed">
                  메스꺼움, 변비, 두통... 불편한 증상이 생기면 바로 기록하세요.
                  기록된 데이터를 의료진과 공유하면 더 나은 상담이 가능해요.
                </p>
                <ul className="mt-6 space-y-3">
                  {["간편한 증상 기록 (원터치)", "기록 데이터 의료진 공유", "심각 증상 시 전문가 상담 안내"].map((item) => (
                    <li key={item} className="flex items-center gap-3 text-warm-gray-300">
                      <svg className="h-5 w-5 text-peach-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
              <div className="flex-1">
                <div className="relative rounded-3xl bg-gradient-to-br from-warm-gray-800 to-warm-gray-900 p-8 shadow-soft-lg">
                  <div className="overflow-hidden rounded-2xl bg-peach-50/10">
                    <Image
                      src="/images/feature-tracking.png"
                      alt="증상 기록 인터페이스"
                      width={500}
                      height={400}
                      className="h-full w-full object-cover"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Feature 3 */}
            <div className={`flex flex-col items-center gap-12 lg:flex-row ${featuresRef.isInView ? 'animate-fade-up delay-600' : 'opacity-0'}`}>
              <div className="flex-1">
                <div className="inline-flex rounded-full bg-mint-500/20 px-4 py-2 text-sm font-medium text-mint-400">
                  데이터 공유 모드
                </div>
                <h3 className="mt-4 text-2xl font-bold text-white sm:text-3xl">
                  진료실에서 말문이 막혀도<br />괜찮아요
                </h3>
                <p className="mt-4 text-warm-gray-400 leading-relaxed">
                  의사 선생님께 보여드릴 깔끔한 리포트가 자동으로 만들어져요.
                  체중 변화, 증상 기록, 투여 이력까지 한눈에 보여드리세요.
                </p>
                <ul className="mt-6 space-y-3">
                  {["기간별 요약 리포트 자동 생성", "읽기 전용 공유 모드", "체중/증상/투여 통합 뷰"].map((item) => (
                    <li key={item} className="flex items-center gap-3 text-warm-gray-300">
                      <svg className="h-5 w-5 text-mint-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
              <div className="flex-1">
                <div className="relative rounded-3xl bg-gradient-to-br from-warm-gray-800 to-warm-gray-900 p-8 shadow-soft-lg">
                  <div className="rounded-2xl bg-white/5 p-6 backdrop-blur">
                    <div className="flex items-center justify-between border-b border-warm-gray-700 pb-4">
                      <div>
                        <p className="text-sm text-warm-gray-400">치료 리포트</p>
                        <p className="text-lg font-semibold text-white">최근 4주 요약</p>
                      </div>
                      <span className="rounded-lg bg-mint-500/20 px-3 py-1 text-xs font-medium text-mint-400">
                        공유 모드
                      </span>
                    </div>
                    <div className="mt-4 grid grid-cols-2 gap-4">
                      <div className="rounded-xl bg-warm-gray-800/50 p-3 text-center">
                        <p className="text-2xl font-bold text-mint-400">-3.2kg</p>
                        <p className="text-xs text-warm-gray-500">체중 변화</p>
                      </div>
                      <div className="rounded-xl bg-warm-gray-800/50 p-3 text-center">
                        <p className="text-2xl font-bold text-white">8회</p>
                        <p className="text-xs text-warm-gray-500">투여 완료</p>
                      </div>
                    </div>
                    <div className="mt-4 rounded-xl bg-warm-gray-800/50 p-3">
                      <p className="text-xs text-warm-gray-400">주요 증상</p>
                      <div className="mt-2 flex flex-wrap gap-2">
                        {["메스꺼움 (3회)", "두통 (1회)"].map((s) => (
                          <span key={s} className="rounded-full bg-warm-gray-700 px-2 py-1 text-xs text-warm-gray-300">
                            {s}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Emotional Journey Section */}
      <section
        ref={journeyRef.ref}
        className="relative py-24 sm:py-32 overflow-hidden"
      >
        <div className="absolute inset-0 gradient-mesh" />

        <div className="relative mx-auto max-w-6xl px-6">
          <div className={`text-center ${journeyRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <h2 className="text-3xl font-bold text-warm-gray-800 sm:text-4xl md:text-5xl">
              두려움에서 희망으로,<br />
              <span className="text-mint-600">당신의 여정을 함께해요</span>
            </h2>
          </div>

          <div className="relative mt-16">
            {/* Journey Line */}
            <div className="absolute left-1/2 top-0 bottom-0 w-px -translate-x-1/2 bg-gradient-to-b from-warm-gray-200 via-mint-300 to-mint-500 hidden md:block" />

            <div className="space-y-12 md:space-y-0">
              {[
                {
                  week: "Week 1",
                  emotion: "두려움 → 안심",
                  title: "처음이라 두려워도 괜찮아요",
                  description: "자가 주사가 낯설지만, 천천히 가이드해 드릴게요. 첫 투여를 무사히 마치는 순간, 할 수 있다는 확신이 생겨요.",
                  emoji: "😰 → 😊",
                  color: "mint",
                },
                {
                  week: "Week 2-4",
                  emotion: "불안 → 적응",
                  title: "몸이 적응하는 시간이에요",
                  description: "메스꺼움이나 불편함이 있을 수 있어요. 하지만 90%가 2주 내 좋아져요. 비우당이 대처법을 알려드릴게요.",
                  emoji: "🤢 → 💪",
                  color: "peach",
                },
                {
                  week: "Week 5-8",
                  emotion: "의심 → 확신",
                  title: "변화가 눈에 보이기 시작해요",
                  description: "꾸준히 기록한 데이터가 변화를 보여줘요. 내가 해내고 있다는 걸 숫자로 확인하는 순간, 자신감이 생겨요.",
                  emoji: "🤔 → 🎉",
                  color: "mint",
                },
                {
                  week: "Week 9-12",
                  emotion: "기대 → 성취",
                  title: "달라진 나를 만나요",
                  description: "12주간의 여정을 완주했어요. 작은 변화들이 쌓여 큰 성취가 되었어요. 이제 건강한 습관이 자리잡았어요.",
                  emoji: "✨ → 🏆",
                  color: "peach",
                },
              ].map((item, index) => (
                <div
                  key={item.week}
                  className={`relative flex flex-col md:flex-row ${index % 2 === 0 ? 'md:flex-row' : 'md:flex-row-reverse'
                    } items-center gap-8 ${journeyRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}
                  style={{ animationDelay: `${index * 200}ms` }}
                >
                  {/* Content Card */}
                  <div className={`flex-1 ${index % 2 === 0 ? 'md:text-right md:pr-12' : 'md:text-left md:pl-12'}`}>
                    <div className={`inline-block rounded-2xl bg-white p-6 shadow-soft-lg text-left ${index % 2 === 0 ? 'md:ml-auto' : ''
                      }`}>
                      <div className={`inline-flex rounded-full px-3 py-1 text-xs font-medium ${item.color === 'mint'
                        ? 'bg-mint-100 text-mint-700'
                        : 'bg-peach-100 text-peach-700'
                        }`}>
                        {item.week}
                      </div>
                      <p className="mt-2 text-sm text-warm-gray-500">{item.emotion}</p>
                      <h3 className="mt-1 text-xl font-semibold text-warm-gray-800">{item.title}</h3>
                      <p className="mt-2 text-warm-gray-600">{item.description}</p>
                      <p className="mt-4 text-2xl">{item.emoji}</p>
                    </div>
                  </div>

                  {/* Center Dot */}
                  <div className={`absolute left-1/2 -translate-x-1/2 hidden md:flex h-12 w-12 items-center justify-center rounded-full ${item.color === 'mint'
                    ? 'bg-mint-500'
                    : 'bg-peach-400'
                    } text-white shadow-soft z-10`}>
                    <span className="text-lg font-bold">{index + 1}</span>
                  </div>

                  {/* Spacer */}
                  <div className="flex-1 hidden md:block" />
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Promise Section */}
      <section
        ref={statsRef.ref}
        className="relative bg-gradient-to-br from-mint-600 via-mint-500 to-mint-600 py-24 sm:py-32 overflow-hidden"
      >
        {/* Decorative Elements */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-0 left-0 h-96 w-96 rounded-full bg-white blur-3xl" />
          <div className="absolute bottom-0 right-0 h-96 w-96 rounded-full bg-white blur-3xl" />
        </div>

        <div className="relative mx-auto max-w-6xl px-6">
          <div className={`text-center ${statsRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <h2 className="text-3xl font-bold text-white sm:text-4xl">
              비우당이 약속해요
            </h2>
            <p className="mt-4 text-lg text-white/80">
              당신의 12주 여정을 위해 우리가 지켜드릴 것들
            </p>
          </div>

          <div className="mt-16 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
            {[
              {
                icon: "🎯",
                title: "목표까지 함께",
                description: "12주 치료 완주를 위한 맞춤 스케줄과 리마인더"
              },
              {
                icon: "🛡️",
                title: "기록으로 소통을",
                description: "증상 기록을 의료진과 공유해 더 나은 상담을 받으세요"
              },
              {
                icon: "📊",
                title: "변화를 눈으로",
                description: "작은 변화도 놓치지 않는 기록과 시각화"
              },
              {
                icon: "🤝",
                title: "혼자가 아니에요",
                description: "진료실에서도, 일상에서도 든든한 동반자"
              },
            ].map((item, index) => (
              <div
                key={item.title}
                className={`rounded-3xl bg-white/10 p-8 text-center backdrop-blur-sm transition-transform hover:scale-105 ${statsRef.isInView ? 'animate-fade-up' : 'opacity-0'
                  }`}
                style={{ animationDelay: `${index * 100}ms` }}
              >
                <span className="text-5xl">{item.icon}</span>
                <p className="mt-4 text-lg font-semibold text-white">{item.title}</p>
                <p className="mt-2 text-sm text-white/80 leading-relaxed">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section
        ref={ctaRef.ref}
        id="download"
        className="relative py-24 sm:py-32"
      >
        <div className="mx-auto max-w-4xl px-6 text-center">
          <div className={`${ctaRef.isInView ? 'animate-fade-up' : 'opacity-0'}`}>
            <h2 className="text-3xl font-bold text-warm-gray-800 sm:text-4xl md:text-5xl">
              12주 후, 달라진 나를<br />
              <span className="text-mint-600">만나러 갈 준비 되셨나요?</span>
            </h2>
            <p className="mx-auto mt-6 max-w-2xl text-lg text-warm-gray-600">
              치료의 시작이 두렵다면, 비우당이 함께할게요.<br />
              작은 변화가 쌓여 큰 성취가 되는 여정, 지금 시작하세요.
            </p>

            <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
              <a
                href="#"
                className="group flex items-center gap-3 rounded-2xl bg-warm-gray-900 px-8 py-4 text-lg font-medium text-white shadow-soft-lg transition-all hover:bg-warm-gray-800 hover:scale-105"
              >
                <svg className="h-7 w-7" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                App Store에서 다운로드
                <span className="transition-transform group-hover:translate-x-1">→</span>
              </a>
              <a
                href="#"
                className="group flex items-center gap-3 rounded-2xl border-2 border-warm-gray-200 bg-white px-8 py-4 text-lg font-medium text-warm-gray-700 transition-all hover:border-warm-gray-900"
              >
                <svg className="h-6 w-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3 20.5v-17c0-.59.34-1.11.84-1.35L13.69 12l-9.85 9.85c-.5-.25-.84-.76-.84-1.35zm13.81-5.38L6.05 21.34l8.49-8.49 2.27 2.27zm3.35-4.31c.34.27.59.69.59 1.19s-.22.9-.57 1.18l-2.29 1.32-2.5-2.5 2.5-2.5 2.27 1.31zM6.05 2.66l10.76 6.22-2.27 2.27L6.05 2.66z" />
                </svg>
                Google Play에서 다운로드
              </a>
            </div>

            {/* Trust Badges */}
            <div className="mt-12 flex flex-wrap items-center justify-center gap-8 text-warm-gray-400">
              <div className="flex items-center gap-2">
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z" />
                </svg>
                <span className="text-sm">의료 정보 보안</span>
              </div>
              <div className="flex items-center gap-2">
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
                </svg>
                <span className="text-sm">무료 사용</span>
              </div>
              <div className="flex items-center gap-2">
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z" />
                </svg>
                <span className="text-sm">4.8 평점</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-warm-gray-200 bg-warm-gray-50 py-12">
        <div className="mx-auto max-w-6xl px-6">
          <div className="flex flex-col items-center justify-between gap-6 md:flex-row">
            <div className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-mint-400 to-mint-600">
                <svg className="h-5 w-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </div>
              <span className="font-display text-lg font-semibold text-warm-gray-800">비우당</span>
            </div>

            <div className="flex flex-wrap justify-center gap-x-6 gap-y-2 text-sm text-warm-gray-500">
              <a href="https://unexpected-vegetarian-236.notion.site/2c52416e3ffa80af9c28e6090b90f433" target="_blank" rel="noopener noreferrer" className="hover:text-warm-gray-800 transition-colors">이용약관</a>
              <a href="https://unexpected-vegetarian-236.notion.site/2c52416e3ffa802ca74defd4ad36c3db" target="_blank" rel="noopener noreferrer" className="hover:text-warm-gray-800 transition-colors">개인정보처리방침</a>
              <a href="https://unexpected-vegetarian-236.notion.site/2c52416e3ffa800b9b0ff2a9b74d7eb1" target="_blank" rel="noopener noreferrer" className="hover:text-warm-gray-800 transition-colors">민감정보 수집동의</a>
              <a href="https://unexpected-vegetarian-236.notion.site/Medical-Disclaimer-2c52416e3ffa80219d19fb5675e53667" target="_blank" rel="noopener noreferrer" className="hover:text-warm-gray-800 transition-colors">의료 면책조항</a>
              <a href="mailto:respawn.99lives@gmail.com" className="hover:text-warm-gray-800 transition-colors">문의하기</a>
            </div>

            <p className="text-sm text-warm-gray-400">
              © 2024 비우당. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
