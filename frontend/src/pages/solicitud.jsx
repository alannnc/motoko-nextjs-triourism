import Image from "next/image";
import { useState } from "react";

function Dashboard() {
  const [selectedOption, setSelectedOption] = useState("Solicitudes");

  const iconMapping = {
    Solicitudes: "/images/iconSolicitude.svg",
    "Detalles de la propiedad": "/images/iconProperty.svg",
    Disponibilidad: "/images/iconDisponibility.svg",
    "Datos de pago": "/images/iconPayment.svg",
  };

  const renderContent = () => {
    switch (selectedOption) {
      case "Solicitudes":
        return <SolicitudesComponent />;
      case "Detalles de la propiedad":
        return <DetallesPropiedadComponent />;
      case "Disponibilidad":
        return <DisponibilidadComponent />;
      case "Datos de pago":
        return <DatosPagoComponent />;
      default:
        return null;
    }
  };

  return (
    <div className="flex flex-col">
      <div className="h-[92px] bg-white pl-5 flex items-center">
        <Image src="/images/logo.svg" width={203} height={48} alt="Logo" />
      </div>

      <div className="bg-[#E3EFFD] flex flex-col px-12 py-6 h-[calc(100vh-92px)]">
        <span className="text-sm font-normal text-[#0F172A] mt-4 mb-6">
          Mis propiedades | Hotel verde | <strong>Solicitudes</strong>
        </span>

        <div className="flex">
          <div className="w-[239px] flex flex-col gap-3">
            {Object.keys(iconMapping).map((option) => (
              <div
                key={option}
                className={`flex items-center border-l-2 h-[40px] px-2 gap-2 cursor-pointer ${
                  selectedOption === option ? "border-[#3581EC]" : "border-[#1C1E21]"
                }`}
                onClick={() => setSelectedOption(option)}>
                <Image src={iconMapping[option]} width={24} height={24} alt={`${option} Icon`} />
                <span className="text-sm font-normal text-[#1C1E21]">{option}</span>
              </div>
            ))}
          </div>

          <div className="flex flex-col fixed right-0 top-[94px] h-[calc(100vh-94px)] w-[440px] rounded-tl-[24px] rounded-bl-[24px] bg-[#FFFFFF] px-6 py-8">
            {renderContent()}
          </div>
        </div>
      </div>
    </div>
  );
}

function SolicitudesComponent() {
  return (
    <div>
      <Image src="/images/iconSolicitude.svg" width={32} height={32} alt="Solicitudes Icon" />
      <span className="text-xl font-bold text-[#1C1E21]">Detalles de reservación</span>
      <div className="flex flex-col w-[381px] rounded-2xl p-4 mt-6 border border-[#64748B] hover:border-[#3581EC]">
        <span className="text-sm font-semibold text-[#1C1E21]">Huésped</span>
        <span className="text-sm font-normal text-[#64748B]">
          Carlos Carrera
          <br />
          Llegada 25/10/2024
          <br />
          Salida 31/10/2024
          <br />2 adultos, 1 niño, 2 perros
        </span>
        <span className="text-sm font-normal text-[#64748B] my-3">Contacto</span>
        <div className="flex">
          <Image src="/images/iconPhone.svg" width={24} height={24} alt="Phone Icon" />
          <span className="text-sm font-normal text-[#64748B]">(+52) 123 456 7890</span>
        </div>
        <div className="flex">
          <Image src="/images/iconEmail.svg" width={24} height={24} alt="Email Icon" />
          <span className="text-sm font-normal text-[#64748B]">hola@hotelverde.com</span>
        </div>
      </div>

      <div className="flex flex-col w-[381px] rounded-2xl p-4 mt-6 border border-[#64748B] hover:border-[#3581EC]">
        <span className="text-sm font-semibold text-[#1C1E21]">Cliente</span>
        <span className="text-sm font-normal text-[#64748B]">
          Carlos Carrera
          <br />
          Pago mediante Tarjeta de crédito $696 MXN
        </span>
        <span className="text-sm font-normal text-[#20961E]">Pago confirmado</span>
        <span className="text-sm font-normal text-[#64748B] my-3">Contacto</span>
        <div className="flex">
          <Image src="/images/iconPhone.svg" width={24} height={24} alt="Phone Icon" />
          <span className="text-sm font-normal text-[#64748B]">(+52) 123 456 7890</span>
        </div>
        <div className="flex">
          <Image src="/images/iconEmail.svg" width={24} height={24} alt="Email Icon" />
          <span className="text-sm font-normal text-[#64748B]">hola@hotelverde.com</span>
        </div>
      </div>

      <button className="h-12 w-full flex items-center justify-center rounded-lg bg-[#0F172A] transition-colors duration-150 ease-in-out">
        <span className="text-sm font-normal text-[#E3EFFD]">Aceptar</span>
      </button>
      <button className="h-12 w-full flex items-center justify-center rounded-lg border border-[#1C1E21] bg-[#FFFFFF]">
        <span className="text-sm font-normal text-[#1C1E21]">Denegar</span>
      </button>
    </div>
  );
}

function DetallesPropiedadComponent() {
  return <div>Contenido de Detalles de la propiedad</div>;
}

function DisponibilidadComponent() {
  return <div>Contenido de Disponibilidad</div>;
}

function DatosPagoComponent() {
  return <div>Contenido de Datos de pago</div>;
}

export default Dashboard;
