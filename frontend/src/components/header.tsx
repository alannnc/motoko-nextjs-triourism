import { InternetIdentityButton } from "@bundly/ares-react";

export default function Header() {
  return (
    <header className="bg-[#1e293b]">
      <nav className="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8" aria-label="Global">
        <span className="text-4xl font-normal text-[#E3EFFD] ">
          Triourism
        </span>
        <div className="lg:flex lg:gap-x-12"></div>
        <div className="lg:flex lg:flex-1 lg:justify-end">
          <InternetIdentityButton />
        </div>
      </nav>
    </header>
  );
}
