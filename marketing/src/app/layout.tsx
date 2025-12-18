import type { Metadata, Viewport } from "next";
import "./globals.css";

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  title: "비우당 | GLP-1 치료의 든든한 동반자",
  description: "12주 후, 달라진 나를 만나보세요. 비우당은 GLP-1 치료 여정을 함께하며, 투여 스케줄 관리부터 증상 기록, 맞춤 인사이트까지 제공합니다.",
  keywords: ["GLP-1", "위고비", "삭센다", "체중감량", "다이어트 앱", "투여 관리", "건강 관리"],
  authors: [{ name: "비우당" }],
  openGraph: {
    title: "비우당 | GLP-1 치료의 든든한 동반자",
    description: "12주 후, 달라진 나를 만나보세요. 투여 스케줄 관리부터 증상 기록까지, 비우당이 함께합니다.",
    type: "website",
    locale: "ko_KR",
    siteName: "비우당",
  },
  twitter: {
    card: "summary_large_image",
    title: "비우당 | GLP-1 치료의 든든한 동반자",
    description: "12주 후, 달라진 나를 만나보세요.",
  },
  robots: "index, follow",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <head>
        <link rel="preconnect" href="https://cdn.jsdelivr.net" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
