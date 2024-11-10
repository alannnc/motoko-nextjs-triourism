import { zodResolver } from "@hookform/resolvers/zod";
import Image from "next/image";
import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

function Dashboard() {
  const [selectedOption, setSelectedOption] = useState(null);

  const handleSelect = (option) => {
    setSelectedOption(option);
  };
  return (
    <>
      <div className="flex flex-col">
        <div className="h-[92px] bg-white pl-5 flex items-center">
          <Image src="/images/logo.svg" width={203} height={48} />
        </div>

        <div className="bg-[#E3EFFD] flex flex-col px-12 py-6 h-[calc(100vh-92px)]">
          <div className="flex justify-between items-center">
            <span className="text-sm font-normal text-[#0F172A] mt-4 mb-6">
              Mis propiedades | Hotel verde | <strong>Solicitudes - Pendientes</strong>
            </span>
          </div>
          <div className="flex justify-start items-start h-full">
            <div className="w-[239px] h-[213px] flex flex-col justify-between">
              <div className="flex w-full border-l-2 border-[#1C1E21] h-[42px] items-center">
                <Image src="/images/iconSolicitude.svg" width={24} height={24} alt="Dashboard Icon" />
                <span className="text-sm font-normal text-[#1C1E21]">Solicitudes </span>
              </div>
              <div className="flex w-full border-l-2 border-[#1C1E21] h-[42px] items-center">
                <Image
                  src="/images/iconProperty.svg"
                  width={24}
                  height={24}
                  alt="Dashboard Icon"
                />
                <span className="text-sm font-normal text-[#1C1E21]">Detalles de la propiedad </span>
              </div>
              <div className="flex w-full border-l-2 border-[#1C1E21] h-[42px] items-center">
                <Image
                  src="/images/iconDisponibility.svg"
                  width={24}
                  height={24}
                  alt="Dashboard Icon"
                />
                <span className="text-sm font-normal text-[#1C1E21]">Disponibilidad </span>
              </div>
              <div className="flex w-full border-l-2 border-[#1C1E21] h-[42px] items-center">
                <Image
                  src="/images/iconPayment.svg"
                  width={24}
                  height={24}
                  alt="Dashboard Icon"
                />
                <span className="text-sm font-normal text-[#1C1E21]">Datos de pago </span>
              </div>
            </div>
          </div>
        </div>
        <div className="flex flex-col fixed right-0 top-[94px] h-[calc(100vh-94px)] w-[440px] rounded-tl-[24px] rounded-bl-[24px] bg-[#FFFFFF] px-6 py-8 justify-between">
          <div>
            <Image src="/images/iconEmpty.svg" width={32} height={32} className="mb-5" alt="Dashboard Icon" />
            <span className="text-xl font-bold text-[#1C1E21]">
              Seleccionar el tipo de reservas para este alojamiento:
            </span>
            <span className="text-sm font-normal text-[#64748B] mt-7">
              Dependiendo de la opción que elijas, la plataforma se ajustará automáticamente a tus
              necesidades.
            </span>
            <div
              onClick={() => handleSelect(1)}
              className={`flex flex-col w-[365px] h-[142px] rounded-2xl p-4 mt-9 cursor-pointer border ${
                selectedOption === 1 ? "border-3 border-[#3581EC]" : "border-[#64748B]"
              } hover:border-[#3581EC]`}>
              <Image src="/images/iconHome.svg" width={24} height={24} alt="Dashboard Icon" />
              <span className="text-sm font-semibold text-[#1C1E21]">
                Reservado en su totalidad para un solo huésped o grupo
              </span>
              <span className="text-sm font-normal text-[#64748B]">
                Ideal si tu alojamiento ofrece una experiencia más personalizada y privada
              </span>
            </div>

            {/* Segundo Div */}
            <div
              onClick={() => handleSelect(2)}
              className={`flex flex-col w-[365px] h-[142px] rounded-2xl p-4 mt-6 cursor-pointer border ${
                selectedOption === 2 ? "border-3 border-[#3581EC]" : "border-[#64748B]"
              } hover:border-[#3581EC]`}>
              <Image src="/images/iconHome.svg" width={24} height={24} alt="Dashboard Icon" />
              <span className="text-sm font-semibold text-[#1C1E21]">Múltiples reservas simultáneas</span>
              <span className="text-sm font-normal text-[#64748B]">
                Ideal si tu alojamiento ofrece servicios estandarizados para muchos huéspedes, como un hotel,
                resort, etc
              </span>
            </div>
          </div>

          <button className="h-12 w-full flex items-center justify-center rounded-lg bg-[#0F172A] transition-colors duration-150 ease-in-out">
            <span className="text-sm font-normal text-[#E3EFFD]">Agregar</span>
          </button>
        </div>
      </div>
    </>
  );
}

export default Dashboard;
