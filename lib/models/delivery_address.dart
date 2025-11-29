class Direccion {
  final int? idDireccion;
  final String nombreDestinatario;
  final String callePrincipal;
  final String numeroExterior;
  final String? informacionAdicional;
  final String ciudad;
  final String estado;
  final String codigoPostal;
  final String pais;
  final bool principalEnvio;

  Direccion({
    this.idDireccion,
    required this.nombreDestinatario,
    required this.callePrincipal,
    required this.numeroExterior,
    this.informacionAdicional,
    required this.ciudad,
    required this.estado,
    required this.codigoPostal,
    required this.pais,
    this.principalEnvio = false,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      idDireccion: json['idDireccion'],
      nombreDestinatario: json['nombreDestinatario'] ?? '',
      callePrincipal: json['callePrincipal'] ?? '',
      numeroExterior: json['numeroExterior'] ?? '',
      informacionAdicional: json['informacionAdicional'],
      ciudad: json['ciudad'] ?? '',
      estado: json['estado'] ?? '',
      codigoPostal: json['codigoPostal'] ?? '',
      pais: json['pais'] ?? '',
      principalEnvio: json['principalEnvio'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idDireccion != null) 'idDireccion': idDireccion,
      'nombreDestinatario': nombreDestinatario,
      'callePrincipal': callePrincipal,
      'numeroExterior': numeroExterior,
      if (informacionAdicional != null) 'informacionAdicional': informacionAdicional,
      'ciudad': ciudad,
      'estado': estado,
      'codigoPostal': codigoPostal,
      'pais': pais,
      'principalEnvio': principalEnvio,
    };
  }
}