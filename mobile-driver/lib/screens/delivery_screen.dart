import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import '../providers/delivery_provider.dart';
import '../providers/location_provider.dart';
import '../services/camera_service.dart';
import '../widgets/navigation_map.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderId;
  
  const DeliveryScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  CameraController? _cameraController;
  String? _photoPath;
  bool _isProcessing = false;
  int _selectedStep = 0;

  final List<DeliveryStep> _steps = [
    DeliveryStep(icon: Icons.camera_alt, title: 'Foto Segel', description: 'Foto dokumen dalam amplop tersegel'),
    DeliveryStep(icon: Icons.directions_car, title: 'Mulai Antar', description: 'Mulai perjalanan antar'),
    DeliveryStep(icon: Icons.attach_money, title: 'Verifikasi COD', description: 'Input jumlah uang diterima'),
    DeliveryStep(icon: Icons.photo_camera, title: 'Foto Bukti', description: 'Foto bukti serah terima'),
    DeliveryStep(icon: Icons.check_circle, title: 'Selesai', description: 'Pesanan selesai'),
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startLocationTracking();
  }

  void _initCamera() async {
    await CameraService.initializeCamera();
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  void _startLocationTracking() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.startTracking();
    locationProvider.startSendingLocation(widget.orderId);
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      final qualityCheck = await CameraService.checkPhotoQuality(photo.path);
      
      if (!qualityCheck.isPass) {
        _showPhotoQualityDialog(qualityCheck.message);
        return;
      }
      
      setState(() {
        _photoPath = photo.path;
      });
      
      // Auto-advance to next step
      await _processCurrentStep();
    } catch (e) {
      _showErrorDialog('Gagal mengambil foto: $e');
    }
  }

  Future<void> _processCurrentStep() async {
    setState(() => _isProcessing = true);
    
    try {
      final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
      
      switch (_selectedStep) {
        case 0: // Sealed photo
          if (_photoPath != null) {
            await deliveryProvider.uploadStartPhoto(widget.orderId, _photoPath!);
            _nextStep();
          }
          break;
          
        case 1: // Start delivery
          await deliveryProvider.startDelivery(widget.orderId);
          _nextStep();
          break;
          
        case 2: // COD verification
          _showCODInputDialog();
          break;
          
        case 3: // Delivery photo
          if (_photoPath != null) {
            await deliveryProvider.completeDelivery(
              widget.orderId,
              _photoPath!,
              _codAmount
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pesanan selesai! E-Receipt telah dikirim via WA'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pushReplacementNamed(context, '/earnings');
          }
          break;
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  double _codAmount = 0;
  
  void _showCODInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Verifikasi COD'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total yang harus dibayar:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Rp ${_orderTotal.toLocaleString()}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah uang diterima',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setStateDialog(() {
                      _codAmount = double.tryParse(value) ?? 0;
                    });
                  },
                ),
                if (_codAmount > 0 && _codAmount < _orderTotal)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Kekurangan: Rp ${(_orderTotal - _codAmount).toLocaleString()}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (_codAmount >= _orderTotal && _codAmount > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Kembalian: Rp ${(_codAmount - _orderTotal).toLocaleString()}',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: _codAmount >= _orderTotal
                    ? () {
                        Navigator.pop(context);
                        _nextStep();
                      }
                    : null,
                child: Text('Konfirmasi'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPhotoQualityDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kualitas Foto Kurang'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ulangi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhoto();
            },
            child: Text('Ambil Ulang'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_selectedStep < _steps.length - 1) {
      setState(() {
        _selectedStep++;
        _photoPath = null;
      });
    }
  }

  double _orderTotal = 0;

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengantaran - Step ${_selectedStep + 1}/${_steps.length}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_steps.length, (index) {
                final isCompleted = index < _selectedStep;
                final isCurrent = index == _selectedStep;
                
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? Colors.green
                              : isCurrent
                                  ? Colors.blue
                                  : Colors.grey[300],
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : _steps[index].icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _steps[index].title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.blue : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          // Map view
          if (_selectedStep >= 1 && _selectedStep <= 2)
            Expanded(
              flex: 3,
              child: NavigationMap(
                orderId: widget.orderId,
                showRoute: true,
                currentLocation: locationProvider.currentLocation,
              ),
            ),
          
          // Camera preview
          if ((_selectedStep == 0 || _selectedStep == 3) && _cameraController != null)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          
          // Action button
          Container(
            padding: EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _takePhoto,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedStep == 0 || _selectedStep == 3
                    ? 'Ambil Foto'
                    : _selectedStep == 1
                        ? 'Mulai Antar'
                        : _selectedStep == 2
                            ? 'Verifikasi COD'
                            : 'Selesai',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryStep {
  final IconData icon;
  final String title;
  final String description;
  
  DeliveryStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}